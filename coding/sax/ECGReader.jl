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
# module ECGReader

# export get_ECGChannel
# export ECGLead
# export ECG
# export ECGChannel
# export list_ECG_channels
# export get_ECGChannel


using CSV, Tables

# include("./Constants.jl")
# using .Constants

function list_ECG_channels(ecg::ECG)::Vector{ECGLead}
    return ecg.channels
end

function get_ECGChannel(ecg::ECG, channel::ECGLead)::ECGChannel
    if channel in ecg.channels
        index = findall(x -> (x == channel), ecg.channels)
        if length(index) == 1
            return ECGChannel(
                channel,
                ecg.sampling_frequency,
                ecg.start_index,
                ecg.end_index,
                ecg.data[:, index[1]],
            )
        else
            # TODO: fix this case
        end
    else
        # TODO: error out
    end
end

"""
Returns the index of the ecg array for a specific time stamp
"""
function get_index_from_timestamp(ecg_pointer::ECGPointer, timestamp::Float64)::UInt64
    if timestamp > get_ECG_duration(ecg_pointer) || timestamp < 0
        # TODO: error out
    end

    return convert(UInt64, round(timestamp * ecg_pointer.sampling_frequency, digits = 0)) +
           1
end

"""
Returns the index of the ecg array for a specific time stamp
"""
function get_index_from_timestamp(ecg_pointer::ECGPointer, timestamp::Int64)::UInt64
    if timestamp > get_ECG_duration(ecg_pointer) || timestamp < 0
        # TODO: error out
    end

    return convert(UInt64, timestamp * ecg_pointer.sampling_frequency) + 1
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
    ECGPointer(filename, unsigned(sampling_frequency), size(data)[1], size(data)[2])
end

"""
Function taking an ecg pointer, start and end indices, selected channels, and
returns an ECG object containing the actual data
"""
function get_ECG(
    ecg_pointer::ECGPointer,
    start_index::UInt64,
    end_index::UInt64,
    channels::Vector{ECGLead},
    extract_channels::Vector{Bool},
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

function read_full_ECGChannel(filename::String, sampling_frequency::Int64, extract_channels::Vector{Bool}, name::ECGLead, n::Int64)::Tuple{ECGChannel,UInt64}
    data::Array{Float64,2} = CSV.File(filename) |> Tables.matrix

    list = Vector{UInt64}()
    for (i, bool) in enumerate(extract_channels)
        if bool
            push!(list, unsigned(i))
        end
    end

    if length(list) == 0
        # TODO: exit out
    end
    
    end_index::UInt64 = length(data[:, 1]) - (length(data[:, 1]) % n)

    w::UInt64 = unsigned((length(data[:, 1]) - (length(data[:, 1]) % speed_ppi)) ÷ speed_ppi)

    return ECGChannel(
        name,
        sampling_frequency,
        1,
        end_index,
        data[1:end_index, list[1]],
    ), w
end

# end #module
