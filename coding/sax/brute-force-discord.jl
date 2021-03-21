"""
Main Function

Author: Moritz M. Konarski
Date: 20.03.2021

Email: konarski_m@auca.kg
GitHub: @moritz-konarski (https://github.com/moritz-konarski)
"""

include("Constants.jl")
include("Statistics.jl")
include("ECGReader.jl")
include("PAA.jl")
include("TSAX.jl")
include("Distance.jl")

fs = 360
filepath = "../mitbih/100.mitbih"
start_index = 78
# start_index2 = 371
start_index2 = 340
# end_index = 720
c = I
channels = [None, I, II]
extract_channels = [false, true, false]
# w = unsigned(12)
w = unsigned(48)
n = unsigned(8)

function get_channel_tsax(start_index::UInt64, length::UInt64)::Tuple{ECGChannel,TSAX}

    end_index::UInt64 = start_index + length
    p = read_csv_file(filepath, fs)

    ecg = get_ECG(p, start_index, end_index, channels, extract_channels)

    channel = get_ECGChannel(ecg, c)

    normalized = normalize_ECGChannel(channel)

    tpaa = calculate_tpaa(normalized, w)

    tsax = calculate_tsax(tpaa, n)
    return channel, tsax
end

function get_channel_esax(start_index::UInt64, length::UInt64)::Tuple{ECGChannel,ESAX}

    end_index::UInt64 = start_index + length
    p = read_csv_file(filepath, fs)

    ecg = get_ECG(p, start_index, end_index, channels, extract_channels)

    channel = get_ECGChannel(ecg, c)

    normalized = normalize_ECGChannel(channel)

    epaa = calculate_epaa(normalized, w)

    esax = calculate_esax(epaa, n)
    return channel, esax
end

function get_channel_sax(start_index::UInt64, length::UInt64)::Tuple{ECGChannel,SAX}

    end_index::UInt64 = start_index + length
    p = read_csv_file(filepath, fs)
    w = (length + 1) ÷ 18

    ecg = get_ECG(p, start_index, end_index, channels, extract_channels)

    channel = get_ECGChannel(ecg, c)

    normalized = normalize_ECGChannel(channel)

    paa = calculate_paa(normalized, w)

    sax = calculate_sax(paa, n)
    return channel, sax
end

function brute_force(sax::SAX, n::Int64)::Tuple{Float64,Int64}
    best_dist::Float64 = 0
    best_location::Int64 = typemax(Int64)
    
    for p in 1:(length(sax.data) - n + 1)
        nearest_dist = typemax(Float64)
        for q in 1:(length(sax.data) - n + 1)
            if abs(p - q) >= n
                cdist = mindist(sub_SAX(sax, p, p+n-1), sub_SAX(sax, q, q+n-1))
                if cdist < nearest_dist
                    nearest_dist = cdist
                end
            end
        end

        if nearest_dist > best_dist
            best_dist = nearest_dist
            best_location = p
        end
    end

    return best_dist, best_location
end

function sub_SAX(s::SAX, start::Int64, stop::Int64)::SAX
    return SAX(s.name, s.sampling_frequency, start, stop, s.w, s.data[start:stop], s.alphabet, s.breakpoints)
end


c1, s1 = get_channel_sax(unsigned(start_index), unsigned(900*720-1))
c1, s1 = get_channel_esax(unsigned(start_index), unsigned(900*720-1))
c1, s1 = get_channel_tsax(unsigned(start_index), unsigned(900*720-1))

# brute_force(s1, 360)