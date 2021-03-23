"""
SUMMARY
Program that finds the top 1 most different segment of an ECG by brute force
using SAX, ESAX, TSAX, and Euclidean Distance

SOURCE
brute force algorithm adapted from:
E. Keogh, J. Lin, A. W. Fu, and H. Van Herle, “Finding Unusual Medical Time-Series Subsequences: Algorithms and Applications,” IEEE Trans. Inform. Technol. Biomed., vol. 10, no. 3, pp. 429–439, Jul. 2006, doi: 10.1109/TITB.2005.863870.

META-INFO
Date: 23.03.2021
Author: Moritz M. Konarski
Email: konarski_m@auca.kg
GitHub: @moritz-konarski (https://github.com/moritz-konarski)
"""

# include files
# ORDER MATTERS
include("Header.jl")
include("Helpers.jl")
include("ECGReader.jl")
include("SAX.jl")
include("ESAX.jl")
include("TSAX.jl")
include("Distance.jl")

# sampling frequency of the ECG
fs = 360
# location of the ECG file (MITBIH file in csv form, command is "rdsamp -r mitdb/113 -p -v -c > 113.mitbih")
filepath = "../mitbih/113.mitbih"
# types of channels in the ECG
channels = [None, I, II]
# which ECG channels to extract
extract_channels = [false, true, false]
# ECG channel to be selected
c = I

"""
Function returning the desired ECG channel and it's TSAX representation
Inputs:
    - start index of the ECG segment
    - end index of the ECG segment
Outputs:
    - normalized ECG Channel
"""
function get_normalized_ECGChannel(start_index::UInt64, end_index::UInt64)::ECGChannel

    # read in the ECG, get a "pointer" to it back
    println("read csv")
    p = read_csv_file(filepath, fs)

    # extract the desired ECG from the csv file
    println("read ECG")
    ecg = get_ECG(p, start_index, end_index, channels, extract_channels)

    # get the desired channel from the ECG
    println("get channel")
    channel = get_ECGChannel(ecg, c)

    # z normalize the ECG channel
    println("z normalize channel")
    return normalize_ECGChannel(channel)
end

"""
Function returning the desired ECG channel and it's TSAX representation
Inputs:
    - start index of the ECG segment
    - end index of the ECG segment
    - w (number of segments for PAA)
    - n (number of letters in TSAX - alphabet size)
Outputs:
    - Tuple of
        - ECG channel
        - TSAX representation of ECG channel
"""
function get_channel_tsax(
    start_index::UInt64,
    end_index::UInt64,
    w::UInt64,
    n::UInt64,
)::Tuple{ECGChannel,TSAX}

    # get a normalized ECG channel
    normalized = get_normalized_ECGChannel(start_index, end_index)

    # calculate the pieacewise aggregate approximation for TSAX
    println("calculate tpaa")
    tpaa = calculate_tpaa(normalized, w)

    # turn tpaa into TSAX representation
    println("calculate tsax")
    tsax = calculate_tsax(tpaa, n)

    return normalized, tsax
end

"""
Function returning the desired ECG channel and it's ESAX representation
Inputs:
    - start index of the ECG segment
    - end index of the ECG segment
    - w (number of segments for PAA)
    - n (number of letters in ESAX - alphabet size)
Outputs:
    - Tuple of
        - ECG channel
        - ESAX representation of ECG channel
"""
function get_channel_esax(
    start_index::UInt64,
    end_index::UInt64,
    w::UInt64,
    n::UInt64,
)::Tuple{ECGChannel,ESAX}

    # get a normalized ECG channel
    normalized = get_normalized_ECGChannel(start_index, end_index)

    # calculate the pieacewise aggregate approximation for ESAX
    println("calculate epaa")
    epaa = calculate_epaa(normalized, w)

    # turn tpaa into ESAX representation
    println("calculate esax")
    esax = calculate_esax(epaa, n)

    return normalized, esax
end

"""
Function returning the desired ECG channel and it's SAX representation
Inputs:
    - start index of the ECG segment
    - end index of the ECG segment
    - w (number of segments for PAA)
    - n (number of letters in SAX - alphabet size)
Outputs:
    - Tuple of
        - ECG channel
        - SAX representation of ECG channel
"""
function get_channel_sax(
    start_index::UInt64,
    end_index::UInt64,
    w::UInt64,
    n::UInt64,
)::Tuple{ECGChannel,SAX}

    # get a normalized ECG channel
    normalized = get_normalized_ECGChannel(start_index, end_index)

    println("calculate PAA")
    paa = calculate_paa(normalized, w)

    println("calculate SAX")
    sax = calculate_sax(paa, n)

    return normalized, sax
end

"""
Function returning the location of most different segment of a SAX representation
Inputs:
    - SAX representation
    - n (length of the sequence to be found)
Outputs:
    - Tuple of
        - highest found distance
        - index of where the highest distance is
"""
function brute_force(sax::SAX, n::Int64)::Tuple{Float64,Int64}
    best_dist::Float64 = typemin(Float64)
    best_location::Int64 = typemax(Int64)
    l = (length(sax.data) - n + 1)

    for p = 1:l
        nearest_dist = typemax(Float64)

        for q = 1:l
            if abs(p - q) >= n
                d = mindist(subsequence(sax, p, p + n - 1), subsequence(sax, q, q + n - 1))
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

"""
Function returning the location of most different segment of a ESAX representation
Inputs:
    - ESAX representation
    - n (length of the sequence to be found)
Outputs:
    - Tuple of
        - highest found distance
        - index of where the highest distance is
"""
function brute_force(esax::ESAX, n::Int64)::Tuple{Float64,Int64}
    best_dist::Float64 = typemin(Float64)
    best_location::Int64 = typemax(Int64)
    l = (length(esax.data) - n + 1)

    for p = 1:l
        nearest_dist = typemax(Float64)

        for q = 1:l
            if abs(p - q) >= n
                d = mindist(
                    subsequence(esax, p, p + n - 1),
                    subsequence(esax, q, q + n - 1),
                )
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

"""
Function returning the location of most different segment of a TSAX representation
Inputs:
    - TSAX representation
    - n (length of the sequence to be found)
Outputs:
    - Tuple of
        - highest found distance
        - index of where the highest distance is
"""
function brute_force(tsax::TSAX, n::Int64)::Tuple{Float64,Int64}
    best_dist::Float64 = typemin(Float64)
    best_location::Int64 = typemax(Int64)
    l = (length(tsax.data) - n + 1)

    for p = 1:l
        nearest_dist = typemax(Float64)

        for q = 1:l
            if abs(p - q) >= n
                d = tsax_dist(
                    subsequence(tsax, p, p + n - 1),
                    subsequence(tsax, q, q + n - 1),
                )
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

"""
Function returning the location of most different segment of a ECG Channel
Inputs:
    - ECG Channel
    - n (length of the sequence to be found)
Outputs:
    - Tuple of
        - highest found distance
        - index of where the highest distance is
"""
function brute_force(channel::ECGChannel, n::Int64)::Tuple{Float64,Int64}
    best_dist::Float64 = 0
    best_location::Int64 = typemax(Int64)
    l = (length(channel.data) - n + 1)

    for p = 1:l
        nearest_dist = typemax(Float64)

        for q = 1:l
            if abs(p - q) >= n
                d = euclidean_distance(
                    subsequence(channel, p, p + n - 1),
                    subsequence(channel, q, q + n - 1),
                )
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

"""
Function returning the subsequence of SAX representation s
starting at start until stop
"""
function subsequence(s::SAX, start::Int64, stop::Int64)::SAX
    # TODO: add safety checks
    return SAX(
        s.name,
        s.sampling_frequency,
        start,
        stop,
        s.w,
        s.data[start:stop],
        s.alphabet,
        s.breakpoints,
    )
end

"""
Function returning the subsequence of ESAX representation s
starting at start until stop
"""
function subsequence(s::ESAX, start::Int64, stop::Int64)::ESAX
    # TODO: add safety checks
    return ESAX(
        s.name,
        s.sampling_frequency,
        start,
        stop,
        s.w,
        s.data[start:stop],
        s.alphabet,
        s.breakpoints,
    )
end

"""
Function returning the subsequence of TSAX representation s
starting at start until stop
"""
function subsequence(s::TSAX, start::Int64, stop::Int64)::TSAX
    # TODO: add safety checks
    return TSAX(
        s.name,
        s.sampling_frequency,
        start,
        stop,
        s.w,
        s.data[start:stop],
        s.bits[((start-1)*length(s.data)÷s.w+1):(stop*length(s.data)÷s.w)],
        s.alphabet,
        s.breakpoints,
    )
end

"""
Function returning the subsequence of ECGChannel s
starting at start until stop
"""
function subsequence(c::ECGChannel, start::Int64, stop::Int64)::ECGChannel
    # TODO: add safety checks
    return ECGChannel(c.name, c.sampling_frequency, start, stop, c.data[start:stop])
end

# standart length to be checked in one go
standard_length = 2 * fs
# is multiplied with standard_length for actual length
length_factor = 15
# starting point of the extracted ECG segment (approx at first R peak)
start_index = 83
# end index of the ECG 
end_index = unsigned(length_factor * standard_length + start_index - 1)
# number of PAA segments per standard_length points (standard_length % w_per_segment == 0)
w_per_segment = 18
# calculating w from w_per_segment
w = unsigned(length_factor * w_per_segment)
# alphabet size, should be <= 26
n = unsigned(7)
# number of PAA segments per heartbeat (approx)
sequence_length = 8

# get the ECG channel and its SAX representation
channel, sax = get_channel_sax(unsigned(start_index), end_index, w, n)

# ignore the ECG channel and get its ESAX representation
_, esax = get_channel_esax(unsigned(start_index), end_index, w, n)

# ignore the ECG channel and get its TSAX representation
_, tsax = get_channel_tsax(unsigned(start_index), end_index, w, n)

# find most different segment by brute force for SAX representation
println("brute force sax")
a, b = brute_force(sax, sequence_length)
println("Max Dist: $a, Segment: $b, Approx Index: $(b * standard_length / w)")

# # find most different segment by brute force for SAX representation
# # ESAX representation is 3 times longer, thus sequence_length is tripled
# println("brute force esax")
# c, d = brute_force(esax, 3 * sequence_length)
# # print the results
# println("Max Dist: $c, Segment: $d, Approx Index: $(d * standard_length / w)")

# # find most different segment by brute force for TSAX representation
# println("brute force tsax")
# e, f = brute_force(tsax, sequence_length)
# println("Max Dist: $e, Segment: $f, Approx Index: $(f * standard_length / w)")

# find most different segment by brute force for SAX representation
println("brute force euclid")
g, h = brute_force(
    channel,
    convert(Int64, round(sequence_length / w_per_segment * standard_length, digits = 0)),
)
println("Max Dist: $g, Index: $h")
