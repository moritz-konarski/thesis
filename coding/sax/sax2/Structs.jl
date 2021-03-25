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
function Parameters(;type::ECGType, start_index::Int64, end_index::Int64, PAA_segment_count::Int64, subsequence_length::Int64, alphabet_size::Int64)::Parameters

    if start_index >= end_index
        @error "Start index must be smaller than end index"
    end

    if (end_index - start_index + 1) % type.fs != 0
        @error "Length of selected ECG range [$start_index, $end_index] must be multiple of sampling frequency $(type.fs)"

    return Parameters(unsigned(0), unsigned(0), unsigned(0), unsigned(0), unsigned(0), type)
    end

    if type.fs % PAA_segment_count != 0 
        @error "PAA segment count $PAA_segment_count must evenly divide sampling frequency $(type.fs)"

    return Parameters(unsigned(0), unsigned(0), unsigned(0), unsigned(0), unsigned(0), type)
    end

    if type.fs % subsequence_length != 0 
        @error "Subsequence length $subsequence_length must evenly divide sampling frequency $(type.fs)"

    return Parameters(unsigned(0), unsigned(0), unsigned(0), unsigned(0), unsigned(0), type)
    end

    if alphabet_size < 2 || alphabet_size > 25
        @error "ERROR: alphabet size $alphabet_size should be in [2, 25]"

    return Parameters(unsigned(0), unsigned(0), unsigned(0), unsigned(0), unsigned(0), type)
    end

    @info "ECG Type: $(type.name)\nParameters:\n  start index: $start_index\n  end index: $end_index\n  PAA segment count: $PAA_segment_count\n  subsequence length: $subsequence_length\n  alphabe size: $alphabet_size"

    return Parameters(unsigned(start_index), unsigned(end_index), unsigned(PAA_segment_count), unsigned(subsequence_length), unsigned(alphabet_size), type)
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
end

"""
Function for the correct instantiation of an ECGPointer
Arguments:
    - type, the type of the ECG
    - filepath, the path from the current Julia environment to the ECG file
Return Type:
    - ECGPointer
"""
function ECGPointer(; filepath::String, param::Parameters)::ECGPointer
    data_point_count::UInt64 = 0
    lead_count::UInt64 = 0

    if param.type.file_extension != SubString(filepath, length(filepath)-3, length(filepath))
        @error "File extension does not match $(param.type.file_extension)"

        path = ""
    end

    path = joinpath(@__DIR__, filepath)

    @info "File path: $path"

    if filesize(path) == 0
        @error "File size is 0, check filepath"

        path = ""
    else
        file = CSV.File(path)
        data_point_count = length(file)
        lead_count = length(file[1])

        if lead_count != length(param.type.leads)
            @error "Number of leads in ECGtype: $(length(param.type.leads)) is different from number of leads in file: $lead_count"

            path = ""
        end

        if data_point_count < param.end_index
            @error "End Index: $(param.end_index) must be less than file length $data_point_count"

            path = ""
        end
    end

    return ECGPointer(param.type, path, data_point_count)
end

"""
Struct for the ECG data
Fields:
    - lead, the lead of the ECG
    - a boolean variable indicating if the ECG is filered
    - a boolean variable indicating if the ECG is normalized 
    - data, a matrix holding the data values
"""
struct ECG
    type::ECGType
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

        lead_index = 0
    elseif length(lead_index) == 1
        lead_index = lead_index[1]
    else
        @error "Multiple leads of same type for ECGType $(pointer.type.name)"
    end

    data::Matrix{Float64} = CSV.File(
        pointer.filepath, 
        skipto=param.start_index+1, 
        limit=param.end_index-param.start_index+1, 
        threaded=false, 
        header=false,
        select=[lead_index]
    ) |> Tables.matrix

    data = reshape(data, :, signed(param.PAA_segment_count * (param.end_index-param.start_index+1) ÷ pointer.type.fs))

    @info "Data matrix has the dimentions (row, col) $(size(data))"

    return ECG(pointer.type, lead, false, false, data)
end