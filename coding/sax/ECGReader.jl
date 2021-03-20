"""
Electrocardiogram Reader

Author: Moritz M. Konarski
Date: 20.03.2021

Email: konarski_m@auca.kg
GitHub: @moritz-konarski (https://github.com/moritz-konarski)
"""

using CSV, Tables

"""
Enum for different types of ECG leads
"None" is for all array elements that are not ECG leads, but other data
(indices, timestamps, ...)
"""
@enum ECGLead begin
    None
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
Struct for the basic properties of an ECG file
"""
struct ECGPointer
    filename::String
    sampling_frequency::UInt64
    length::UInt64
    channels::UInt64
end

"""
Struct for the ECG
"""
struct ECG
    sampling_frequency::UInt64
    start_index::UInt64
    end_index::UInt64
    data::Array{Float64,2}
    channels::Array{ECGLead}
end

"""
Returns the index of the ecg array for a specific time stamp
"""
function get_index_from_timestamp(
    ecg_pointer::ECGPointer,
    timestamp::Float64,
)::UInt64
    if timestamp > get_ECG_duration(ecg_pointer) || timestamp < 0
        # TODO: error out
    end

    return convert(
        UInt64,
        round(timestamp * ecg_pointer.sampling_frequency, digits = 0),
    ) + 1
end

"""
Returns the index of the ecg array for a specific time stamp
"""
function get_index_from_timestamp(
    ecg_pointer::ECGPointer,
    timestamp::Int64,
)::UInt64
    if timestamp > get_ECG_duration(ecg_pointer) || timestamp < 0
        # TODO: error out
    end

    return convert(
        UInt64,
        timestamp * ecg_pointer.sampling_frequency
    ) + 1
end

"""
Function computing the length (in seconds) of the ecg
"""
function get_ECG_duration(ecg_pointer::ECGPointer)::Float64
    return ecg_pointer.length / ecg_pointer.sampling_frequency
end

"""
Function computing the length (in seconds) of the ecg
"""
function get_ECG_duration(ecg::ECG)::Float64
    range::UInt64 = ecg.end_index - ecg.start_index
    return range / ecg_pointer.sampling_frequency
end

"""
Function reading in an ECG file in ecg format and then returning a "pointer"
to it
"""
function read_csv_file(filename::String, sampling_frequency::Int64)::ECGPointer
    data::Array{Float64,2} = CSV.File(filename) |> Tables.matrix
    ECGPointer(
        filename,
        unsigned(sampling_frequency),
        size(data)[1],
        size(data)[2],
    )
end

"""
Function taking an ecg pointer, start and end indices, selected channels, and
returns an ECG object containing the actual data
"""
function get_ECG(
    ecg_pointer::ECGPointer,
    start_index::UInt64,
    end_index::UInt64,
    channels::Array{ECGLead,1},
    extract_channels::Array{Bool,1},
)::ECG
    if start_index >= end_index ||
       start_index < 1 ||
       end_index > ecg_pointer.length ||
       length(extract_channels) != ecg_pointer.channels ||
       length(channels) != ecg_pointer.channels
        # TODO: exit out
    end

    list = Vector{UInt64}()
    for (i, bool) in enumerate(extract_channels)
        if bool
            push!(list, unsigned(i))
        end
    end

    if length(list) == 0
        # TODO: exit out
    end

    data::Array{Float64,2} = CSV.File(ecg_pointer.filename) |> Tables.matrix
    ECG(
        ecg_pointer.sampling_frequency,
        unsigned(start_index),
        unsigned(end_index),
        data[start_index:end_index, list],
        channels[list],
    )
end

function get_ECG(
    ecg_pointer::ECGPointer,
    start_index::Int64,
    end_index::Int64,
    channels::Array{ECGLead,1},
    extract_channels::Array{Bool,1},
)::ECG
    return get_ECG(
        ecg_pointer,
        unsigned(start_index),
        unsigned(end_index),
        channels,
        extract_channels,
    )
end
