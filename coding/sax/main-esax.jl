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
include("ESAX.jl")
include("Distance.jl")

fs = 360
filepath = "../mitbih/100.mitbih"
start_index = 78
# start_index2 = 371
start_index2 = 340
end_index = 720
c = I
channels = [None, I, II]
extract_channels = [false, true, false]
# w = unsigned(12)
w = unsigned(48)
n = unsigned(8)

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

c1, s1 = get_channel_esax(unsigned(start_index), unsigned(719))

c2, s2 = get_channel_esax(unsigned(start_index2), unsigned(719))

println("E = $(euclidean_distance(c1, c2))")
println("m = $(mindist(s1, s2))")
println("tolb = $(tightness_of_lower_bound(c1 ,c2, s1, s2))")
