"""
SUMMARY
Structs and their instantiations functions

META-INFO
Date: 25.03.2021
Author: Moritz M. Konarski
Email: konarski_m@auca.kg
GitHub: @moritz-konarski (https://github.com/moritz-konarski)
"""

using CSV, Tables

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
Arguments:
    - ECGType, type of the ECG to be used
    - start index from where the ecg file is read
    - end index to where the ecg file is read
    - PAA segment count, number of PAA segments per sampling frequency points
    - length of each PAA subsequence, number of PAA segments per subsequence
    - alphabet size, size of the alphabet used for SAX calculation
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

    @info "ECG Type: $(type.name)\nParameters:\n  start index: $start_index\n  end index: $end_index\n  PAA segment count: $PAA_segment_count\n  subsequence length: $subsequence_length\n  alphabe size: $alphabet_size"

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
    - type, the type of the ECG
    - filepath, the path from the current Julia environment to the ECG file
    - number of data points in the file
    - number of leads in the file
"""
struct ECGPointer
    type::ECGType
    filepath::String
    data_point_count::UInt64
    number::UInt64
end

"""
Function for the correct instantiation of an ECGPointer
Arguments:
    - type, the type of the ECG
    - filepath, the path from the current Julia environment to the ECG file
    - number of the ECG from the database
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

    @info "File path: $path"

    if filesize(path) == 0
        @error "File size is 0, check filepath"

        throw(DomainError(filepath))
    else
        file = CSV.File(path)
        data_point_count = length(file)
        lead_count = length(file[1])

        if lead_count != length(param.type.leads)
            @error "Number of leads in ECGtype: $(length(param.type.leads)) is different from number of leads in file: $lead_count"

            throw(DomainError(filepath))
        end

        if data_point_count < param.end_index
            @error "End Index: $(param.end_index) must be less than file length $data_point_count"

            throw(DomainError(filepath))
        end
    end

    return ECGPointer(param.type, path, data_point_count, unsigned(number))
end

"""
Struct for the ECG data
Fields:
    - lead, the lead of the ECG
    - number, the number of the ECG in the database
    - a boolean variable indicating if the ECG is filered
    - a boolean variable indicating if the ECG is normalized 
    - data, a matrix holding the data values
"""
struct ECG
    type::ECGType
    number::UInt64
    lead::ECGLead
    is_filtered::Bool
    is_normalized::Bool
    data::Matrix{Float64}
end

"""
Function for the instantiation of the ECG struct
Arguments:
    - type of the ECG
    - parameters of the program
    - lead of the ECG file to be extracted
    - pointer to the ECG file
"""
function ECG(; param::Parameters, lead::ECGLead, pointer::ECGPointer)::ECG

    lead_index = findall(x -> (x == lead), pointer.type.leads)

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

    data = reshape(
        data,
        :,
        signed(
            param.PAA_segment_count * (param.end_index - param.start_index + 1) ÷
            pointer.type.fs ÷ param.subsequence_length,
        ),
    )

    @info "Data matrix has the dimensions $(size(data))"

    return ECG(pointer.type, pointer.number, lead, false, false, data)
end


"""
Struct for PAA data 
Fields:
    - data, a matrix holding the data values
"""
struct PAA
    data::Matrix{Float64}
end

function PAA(; ecg::ECG, param::Parameters)::PAA

    @info "Calculating PAA"

    rows::UInt64 = size(ecg.data)[1]
    cols::UInt64 = size(ecg.data)[2]
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

    return PAA(paa)
end

struct SAX
    type::ECGType
    number::UInt64
    lead::ECGLead
    difference_matrix::Matrix{Float64}
    data::Matrix{Char}
end

function SAX(; paa::PAA, param::Parameters, ecg::ECG)::SAX

    @info "Calculating SAX"

    β::Vector{Float64} = compute_breakpoints(alphabet_size = param.alphabet_size)
    α::Vector{Char} = compute_alphabet(alphabet_size = param.alphabet_size)

    rows, cols = size(paa.data)

    sax::Matrix{Char} = fill(last(α), size(paa.data))

    for i = 1:rows
        for j = 1:cols
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

    return SAX(ecg.type, ecg.number, ecg.lead, difference_matrix, sax)
end
