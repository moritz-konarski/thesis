"""
Electrocardiogram Reader

Author: Moritz M. Konarski
Date: 20.03.2021

Email: konarski_m@auca.kg
GitHub: @moritz-konarski (https://github.com/moritz-konarski)
"""

"""
Module of the ECGReader
"""

using CSV, Tables

# function list_ECG_channels(ecg::ECG)::Vector{ECGLead}
#     return ecg.channels
# end

function get_ECGChannel(ecg::ECG, channel::ECGLead)::ECGChannel
    return ECGChannel(
        channel,
        ecg.sampling_frequency,
        ecg.start_index,
        ecg.end_index,
        ecg.data[:, channel .== ecg.channels][:],
    )
end

# """
# Returns the index of the ecg array for a specific time stamp
# """
# function get_index_from_timestamp(ecg_pointer::ECGPointer, timestamp::Float64)::UInt64
#     if timestamp > get_ECG_duration(ecg_pointer) || timestamp < 0
#         # TODO: error out
#     end

#     return convert(UInt64, round(timestamp * ecg_pointer.sampling_frequency, digits = 0))
# end

# """
# Returns the index of the ecg array for a specific time stamp
# """
# function get_index_from_timestamp(ecg_pointer::ECGPointer, timestamp::Int64)::UInt64
#     if timestamp > get_ECG_duration(ecg_pointer) || timestamp < 0
#         # TODO: error out
#     end

#     return convert(UInt64, timestamp * ecg_pointer.sampling_frequency) + 1
# end

# """
# Function computing the length (in seconds) of the ecg
# """
# function get_ECG_duration(ecg_pointer::ECGPointer)::Float64
#     return ecg_pointer.length / ecg_pointer.sampling_frequency
# end

# """
# Function computing the length (in seconds) of the ecg
# """
# function get_ECG_duration(ecg::ECG)::Float64
#     range::UInt64 = ecg.end_index - ecg.start_index
#     return range / ecg_pointer.sampling_frequency
# end

"""
Function reading in an ECG file in ecg format and then returning a "pointer"
to it
"""
function read_csv_file(filename::String, sampling_frequency::Int64)::ECGPointer
    file = CSV.File(filename)
    row::UInt64 = length(file)
    col::UInt64 = length(file[1])
    ECGPointer(filename, unsigned(sampling_frequency), row, col)
end

"""
Function taking an ecg pointer, start and end indices, selected channels, and
returns an ECG object containing the actual data
"""
function get_ECG(
    p::ECGPointer,
    start::UInt64,
    stop::UInt64,
    channels::Vector{ECGLead},
    extract_channels::Vector{Bool},
)::ECG
    if start >= stop ||
       start < 1 ||
       stop > p.length ||
       length(extract_channels) != p.channels ||
       length(channels) != p.channels
        # TODO: exit out
    end
    
    data::Array{Float64,2} = CSV.File(
        p.filename, 
        skipto=start+1, 
        limit=stop-start, 
        threaded=false, 
        header=false,
        select=extract_channels
    ) |> Tables.matrix

    ECG(
        p.sampling_frequency,
        unsigned(start),
        unsigned(stop),
        data,
        channels[extract_channels],
    )
end

function get_ECG(
    ecg_pointer::ECGPointer,
    start_index::Int64,
    end_index::Int64,
    channels::Vector{ECGLead},
    extract_channels::Vector{Bool},
)::ECG
    return get_ECG(
        ecg_pointer,
        unsigned(start_index),
        unsigned(end_index),
        channels,
        extract_channels,
    )
end