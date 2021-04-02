"""
SUMMARY
Structs and their instantiations functions

Author: Moritz M. Konarski
Email: konarski_m@auca.kg
GitHub: @moritz-konarski (https://github.com/moritz-konarski)
"""

# for reading the ECG files
using CSV
# for converting read ECG files to matrices
using Tables
# provides dataframes
using DataFrames

"""
Enumeration of different types of ECG leads contained in ECG files
"""
@enum ECGLead begin
    Seconds
    PointIndex
    I
    II
    III
    aVR
    aVL
    aVF
    V1
    V2
    V3
    V4
    V5
    V6
end

"""
Struct for information on the type of the ECG
Fields:
    - name of the ECG (e.g. MITBIH)
    - leads in the ecg
    - fs, the sampling frequency of the ECG (per second)
    - file extension of the ecg files
"""
struct ECGType
    name::String
    leads::Vector{ECGLead}
    fs::UInt64
    file_extension::String
end

# ECGType for MITBIH ecg files (https://www.physionet.org/content/mitdb/1.0.0/)
const MITBIH = ECGType("MIT-BIH", [Seconds, II, V1], unsigned(360), ".mit")

# ECGType for ST-T ecg files (https://www.physionet.org/content/edb/1.0.0/)
const STT = ECGType("ST-T", [Seconds, V4, III], unsigned(250), ".stt")

"""
Struct for the parameters of the program
Fields:
    - start index from where the ecg file is read
    - end index to where the ecg file is read
    - PAA segment count, number of PAA segments per sampling frequency points
    - length of each PAA subsequence, number of PAA segments per subsequence
    - alphabet size, size of the alphabet used for SAX calculation
    - type of the ECG
"""
struct Parameters
    start_index::UInt64
    end_index::UInt64
    PAA_segment_count::UInt64
    subsequence_length::UInt64
    alphabet_size::UInt64
    type::ECGType
end

"""
Function to correctly instantiate the Parameters struct
keyword arguments:
    - type: ECGType, type of the ECG to be used
    - start_index: start index from where the ecg file is read
    - end_index: end index to where the ecg file is read
    - paa_segment_length: PAA segment count, number of PAA segments per sampling frequency points
    - subsequence_length: length of each PAA subsequence, number of PAA segments per subsequence
    - alphabet_size: alphabet size, size of the alphabet used for SAX calculation
Return Type:
    - Parameters struct
"""
function Parameters(;
    type::ECGType,
    start_index::Int64,
    end_index::Int64,
    PAA_segment_count::Int64,
    subsequence_length::Int64,
    alphabet_size::Int64,
)::Parameters

    if start_index >= end_index
        @error "Start index must be smaller than end index"

        throw(DomainError(start_index))
    end

    if (end_index - start_index + 1) % type.fs != 0
        @error "Length of selected ECG range [$start_index, $end_index] must be multiple of sampling frequency $(type.fs)"

        throw(DomainError(end_index - start_index + 1))
    end

    if type.fs % PAA_segment_count != 0
        @error "PAA segment count $PAA_segment_count must evenly divide sampling frequency $(type.fs)"

        throw(DomainError(PAA_segment_count))
    end

    if type.fs % subsequence_length != 0
        @error "Subsequence length $subsequence_length must evenly divide sampling frequency $(type.fs)"

        throw(DomainError(subsequence_length))
    end

    if alphabet_size < 2 || alphabet_size > 25
        @error "ERROR: alphabet size $alphabet_size should be in [2, 25]"

        throw(DomainError(alphabet_size))
    end

    @info "Parameters\n  ECG Type: $(type.name)\n  start index: $start_index\n  end index: $end_index\n  PAA segment count: $PAA_segment_count\n  subsequence length: $subsequence_length\n  alphabe size: $alphabet_size"

    return Parameters(
        unsigned(start_index),
        unsigned(end_index),
        unsigned(PAA_segment_count),
        unsigned(subsequence_length),
        unsigned(alphabet_size),
        type,
    )
end

"""
Struct for the ECG Pointer, a reference to the ECG file on the computer 
Fields:
    - filepath: the path from the current Julia environment to the ECG file
    - data_point_count: number of data points in the file
    - number: number of leads in the file
"""
struct ECGPointer
    data_point_count::UInt64
    number::UInt64
    filepath::String
end

"""
Function for the correct instantiation of an ECGPointer
keyword arguments:
    - filepath: the path from the current Julia environment to the ECG file
    - number: number of the ECG from the database
    - param: the parameters of the program
Return Type:
    - ECGPointer
"""
function ECGPointer(; filepath::String, param::Parameters, number::Int64)::ECGPointer
    data_point_count::UInt64 = 0
    lead_count::UInt64 = 0

    if param.type.file_extension !=
       SubString(filepath, length(filepath) - 3, length(filepath))
        @error "File extension does not match $(param.type.file_extension)"

        throw(DomainError(filepath))
    end

    path = joinpath(@__DIR__, filepath)


    if filesize(path) == 0
        @error "File size is 0, check filepath"

        throw(DomainError(filepath))
    else
        lead_count = length(
            CSV.File(path, skipto = param.start_index + 1, limit = 1) |> Tables.matrix,
        )

        if lead_count != length(param.type.leads)
            @error "Number of leads in ECGtype: $(length(param.type.leads)) is different from number of leads in file: $lead_count"

            throw(DomainError(filepath))
        end
    end

    @info "File path: $path"

    return ECGPointer(data_point_count, unsigned(number), path)
end

"""
Struct for the ECG data
Fields:
    - number: number of the ECG in it's collection
    - lead: the lead of the ECG
    - is_filtered: a boolean variable indicating if the ECG is filered
    - is_normalized: a boolean variable indicating if the ECG is normalized 
    - data: a matrix holding the data values
"""
struct ECG
    number::UInt64
    lead::ECGLead
    is_filtered::Vector{Bool}
    is_normalized::Vector{Bool}
    data::Matrix{Float64}
end

"""
Function for the instantiation of the ECG struct
keyword arguments:
    - param: parameters of the program
    - lead: lead of the ECG file to be extracted
    - pointer: pointer to the ECG file
Return type:
    - ECG
"""
function ECG(; param::Parameters, lead::ECGLead, pointer::ECGPointer)::ECG

    @info "Extracting ECG"

    lead_index = findall(x -> (x == lead), param.type.leads)

    if length(lead_index) == 0
        @error "Lead is invalid for ECGType $(pointer.type.name)"

        throw(DomainError(lead))
    elseif length(lead_index) == 1
        lead_index = lead_index[1]
    else
        @error "Multiple leads of same type for ECGType $(pointer.type.name)"

        throw(DomainError(lead))
    end

    data::Matrix{Float64} =
        CSV.File(
            pointer.filepath,
            skipto = param.start_index + 1,
            limit = param.end_index - param.start_index + 1,
            threaded = false,
            header = false,
            select = [lead_index],
        ) |> Tables.matrix

    if size(data, 1) < (param.end_index - param.start_index + 1)
        @error "End Index: $(param.end_index) must be less than file length $(size(data, 1))"

        throw(DomainError(param.end_index))
    end

    data = reshape(
        data,
        :,
        signed(
            param.PAA_segment_count * (param.end_index - param.start_index + 1) ÷
            param.type.fs ÷ param.subsequence_length,
        ),
    )

    @info "Data matrix has the dimensions $(size(data))"

    return ECG(pointer.number, lead, [false], [false], data)
end

"""
Struct for PAA data 
Fields:
    - number, the number of the ECG
    - lead, lead of the ECG
    - data, a matrix holding the data values
"""
struct PAA
    number::UInt64
    lead::ECGLead
    data::Matrix{Float64}
end

"""
Function for the calulcation of PAA
keyword arguments:
    - ecg: ECG that PAA to be applied throw
    - param: parameters of the ECG
Return type:
    - PAA (wrapper around Matrix{Float64})
"""
function PAA(; ecg::ECG, param::Parameters)::PAA

    @info "Calculating PAA"

    rows::UInt64 = size(ecg.data, 1)
    cols::UInt64 = size(ecg.data, 2)
    len::UInt64 = rows * cols
    points_per_segment::UInt64 = rows ÷ param.subsequence_length

    paa::Matrix{Float64} = zeros(Float64, rows ÷ points_per_segment, cols)

    for i = 1:cols
        for j = 1:param.subsequence_length
            paa[j, i] =
                sum(ecg.data[((j-1)*points_per_segment+1):(j*points_per_segment), i])
        end
    end

    paa *= (cols * param.subsequence_length / len)

    return PAA(ecg.number, ecg.lead, paa)
end

"""
Struct for SAX data 
Fields:
    - number: number of the ECG
    - lead: lead that the ECG is from
    - difference_matrix: matrix used for the computation of distances between two segments
    - data, a matrix holding the data values
"""
struct SAX
    number::UInt64
    lead::ECGLead
    difference_matrix::Matrix{Float64}
    data::Matrix{Char}
end

"""
Function for the calulcation of SAX
keyword arguments:
    - paa: the PAA representation of the ECG
    - param: parameters of the ECG
Return type:
    - SAX representation
"""
function SAX(; paa::PAA, param::Parameters)::SAX

    @info "Calculating SAX"

    β::Vector{Float64} = compute_breakpoints(alphabet_size = param.alphabet_size)
    α::Vector{Char} = compute_alphabet(alphabet_size = param.alphabet_size)

    rows, cols = size(paa.data)

    sax::Matrix{Char} = fill(last(α), rows, cols)

    for j = 1:cols
        for i = 1:rows
            for (k, βk) in enumerate(β)
                if paa.data[i, j] < βk
                    sax[i, j] = α[k]
                    break
                end
            end
        end
    end

    difference_matrix::Matrix{Float64} =
        zeros(Float64, param.alphabet_size, param.alphabet_size)

    for i = 1:param.alphabet_size
        for j = 1:param.alphabet_size
            if abs(i - j) > 1
                if j > i
                    difference_matrix[i, j] = β[j-1] - β[i]
                    difference_matrix[j, i] = difference_matrix[i, j]
                end
            end
        end
    end

    return SAX(paa.number, paa.lead, difference_matrix, sax)
end

"""
Struct for the Annotation Pointer, a reference to the ECG annotation file on the computer 
Fields:
    - filepath: the path from the current Julia environment to the annotation file
    - data_point_count: number of data points in the file
    - number: number of leads in the file
"""
struct AnnotationPointer
    data_point_count::UInt64
    number::UInt64
    filepath::String
end

"""
Function for the correct instantiation of an AnnotationPointer
keyword arguments:
    - filepath: the path from the current Julia environment to the ECG file
    - number: number of the ECG from the database
    - param: the parameters of the program
Return Type:
    - AnnotationPointer
"""
function AnnotationPointer(; filepath::String, param::Parameters, number::Int64)::AnnotationPointer
    data_point_count::UInt64 = 0

    if param.type.file_extension !=
       SubString(filepath, length(filepath) - 3, length(filepath))
        @error "File extension does not match $(param.type.file_extension)"

        throw(DomainError(filepath))
    end

    path = joinpath(@__DIR__, filepath)

    if filesize(path) == 0
        @error "File size is 0, check filepath"

        throw(DomainError(filepath))
    end

    @info "File path: $path"

    return AnnotationPointer(data_point_count, unsigned(number), path)
end

"""
Struct for the Annotation data
Fields:
    - number: number of the annotation in it's collection
    - data: a matrix holding the data values
"""
struct Annotation
    number::UInt64
    data::DataFrame
end

"""
Function for the instantiation of the annotation struct
keyword arguments:
    - param: parameters of the program
    - pointer: pointer to the ECG file
Return type:
    - Annotation
"""
function Annotation(; param::Parameters, pointer::AnnotationPointer)::Annotation

    @info pointer
    @info "Extracting Annotations"

    data =
        CSV.File(
            pointer.filepath,
            types = [Int64, String, Int64, Int64, Int64, String],
        ) |> DataFrame

    @info "Data matrix has the dimensions $(size(data))"

    return Annotation(pointer.number, data)
end