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
include("SAX.jl")
include("ESAX.jl")
include("TSAX.jl")
include("Distance.jl")

fs = 250
filepath = "../mitbih/103.mitbih"
start_index = 83
# start_index2 = 371
# start_index2 = 340
# end_index = 720
c = V4
channels = [None, V4, III]
extract_channels = [false, true, false]
# w = unsigned(12)
# w = unsigned(48)
# n = unsigned(8)

function get_channel_tsax(start_index::UInt64, end_index::UInt64, w::UInt64, n::UInt64)::Tuple{ECGChannel,TSAX}

    println("read csv")
    # end_index::UInt64 = start_index + length
    p = read_csv_file(filepath, fs)
    # w = (length + 1) ÷ n

    println("read ECG")
    ecg = get_ECG(p, start_index, end_index, channels, extract_channels)

    println("get channel")
    channel = get_ECGChannel(ecg, c)

    println("normalize channel")
    normalized = normalize_ECGChannel(channel)

    println("calculate tpaa")
    tpaa = calculate_tpaa(normalized, w)
    # println(length(tpaa.data))

    println("calculate tsax")
    tsax = calculate_tsax(tpaa, n)
    return channel, tsax
end

function get_channel_esax(start_index::UInt64, end_index::UInt64, w::UInt64, n::UInt64)::Tuple{ECGChannel,ESAX}

    println("read csv")
    # end_index::UInt64 = start_index + length
    p = read_csv_file(filepath, fs)
    # w = (length + 1) ÷ n

    println("read ECG")
    ecg = get_ECG(p, start_index, end_index, channels, extract_channels)

    println("get channel")
    channel = get_ECGChannel(ecg, c)

    println("normalize channel")
    normalized = normalize_ECGChannel(channel)

    println("calculate epaa")
    epaa = calculate_epaa(normalized, w)

    println("calculate esax")
    esax = calculate_esax(epaa, n)
    return channel, esax
end

function get_channel_sax(start_index::UInt64, end_index::UInt64, w::UInt64, n::UInt64)::Tuple{ECGChannel,SAX}

    println("read csv")
    # end_index::UInt64 = start_index + length
    p = read_csv_file(filepath, fs)
    # w = (length + 1) ÷ n

    println("read ECG")
    ecg = get_ECG(p, start_index, end_index, channels, extract_channels)

    println("get channel")
    channel = get_ECGChannel(ecg, c)

    println("normalize channel")
    normalized = normalize_ECGChannel(channel)

    println("calculate PAA")
    paa = calculate_paa(normalized, w)

    println("calculate SAX")
    sax = calculate_sax(paa, n)
    return channel, sax
end

function brute_force(sax::SAX, n::Int64)::Tuple{Float64,Int64}
    best_dist::Float64 = typemin(Float64)
    best_location::Int64 = typemax(Int64)
    l = (length(sax.data) - n + 1)
    
    for p in 1:l
        # println("$p / $l")
        nearest_dist = typemax(Float64)

        for q in 1:l
            # println("   $q / $l")
            if abs(p - q) >= n
                d = mindist(sub_SAX(sax, p, p+n-1), sub_SAX(sax, q, q+n-1))
                # println(nearest_dist)
                if d < nearest_dist
                    nearest_dist = d
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

function brute_force(esax::ESAX, n::Int64)::Tuple{Float64,Int64}
    best_dist::Float64 = typemin(Float64)
    best_location::Int64 = typemax(Int64)
    l = (length(esax.data) - n + 1)
    
    for p in 1:l
        # println("$p / $l")
        nearest_dist = typemax(Float64)

        for q in 1:l
            # println("   $q / $l")
            if abs(p - q) >= n
                d = mindist(sub_ESAX(esax, p, p+n-1), sub_ESAX(esax, q, q+n-1))
                # println(nearest_dist)
                if d < nearest_dist
                    nearest_dist = d
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

function brute_force(tsax::TSAX, n::Int64)::Tuple{Float64,Int64}
    best_dist::Float64 = typemin(Float64)
    best_location::Int64 = typemax(Int64)
    l = (length(tsax.data) - n + 1)
    
    for p in 1:l
        # println("$p / $l")
        nearest_dist = typemax(Float64)

        for q in 1:l
            # println("   $q / $l")
            if abs(p - q) >= n
                # println("$p $q")
                d = tsax_dist(sub_TSAX(tsax, p, p+n-1), sub_TSAX(tsax, q, q+n-1))
                # println(nearest_dist)
                if d < nearest_dist
                    nearest_dist = d
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

function brute_force(channel::ECGChannel, n::Int64)::Tuple{Float64,Int64}
    best_dist::Float64 = 0
    best_location::Int64 = typemax(Int64)
    l = (length(channel.data) - n + 1)
    
    for p in 1:l
        # println("$p / $l")
        nearest_dist = typemax(Float64)

        for q in 1:l
            if abs(p - q) >= n
                d = euclidean_distance(sub_ECGChannel(channel, p, p+n-1), sub_ECGChannel(channel, q, q+n-1))
                if d < nearest_dist
                    nearest_dist = d
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
    # TODO: add safety checks
    return SAX(s.name, s.sampling_frequency, start, stop, s.w, s.data[start:stop], s.alphabet, s.breakpoints)
end

function sub_ESAX(s::ESAX, start::Int64, stop::Int64)::ESAX
    # TODO: add safety checks
    return ESAX(s.name, s.sampling_frequency, start, stop, s.w, s.data[start:stop], s.alphabet, s.breakpoints)
end

function sub_TSAX(s::TSAX, start::Int64, stop::Int64)::TSAX
    # TODO: add safety checks
    # println(start)
    # println(stop)
    return TSAX(s.name, s.sampling_frequency, start, stop, s.w, s.data[start:stop], s.bits[((start-1)*length(s.data) ÷ s.w+1):(stop*length(s.data) ÷ s.w)] , s.alphabet, s.breakpoints)
end

function sub_ECGChannel(c::ECGChannel, start::Int64, stop::Int64)::ECGChannel
    # TODO: add safety checks
    return ECGChannel(c.name, c.sampling_frequency, start, stop, c.data[start:stop])
end

length_factor = 15
end_index = unsigned(length_factor* 2 * fs +start_index-1)
# w = unsigned(length_factor * 36)
w = unsigned(length_factor * 20)
# n = unsigned(9)
n = unsigned(7)

c1, s1 = get_channel_sax(unsigned(start_index), end_index, w, n)

_, s2 = get_channel_esax(unsigned(start_index), end_index, w, n)

_, s3 = get_channel_tsax(unsigned(start_index), end_index, w, n)

println("brute force sax")
a, b = brute_force(s1, 10)
println((a, b, b * 320/8))

println("brute force esax")
c, d = brute_force(s2, 8*3)
println((c, d, d * 320/8))

println("brute force tsax")
e, f = brute_force(s3, 10)
println((e, f, f * 320/8))

println("brute force euclid")
println(brute_force(c1, 320))

# (2.5607469613376486, 1726)
# (10.037811016352121, 8372)

# brute force sax
# (5.582262406533327, 35, 1400.0)
# brute force esax
# (38.286588601218014, 31, 1240.0)
# brute force tsax
# (6.2851159496436555, 35, 1400.0)
# brute force euclid
# (5.650161502116553, 1340)