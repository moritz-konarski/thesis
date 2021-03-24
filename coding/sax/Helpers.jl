"""
Piecewise Aggregate Approximation for SAX Implementation

Author: Moritz M. Konarski
Date: 20.03.2021

Email: konarski_m@auca.kg
GitHub: @moritz-konarski (https://github.com/moritz-konarski)
"""

"""
Module to perform PAA
"""

using StatsBase
using StatsFuns

# function normalize_ECGChannel(ec::ECGChannel)::ECGChannel
#     return ECGChannel(
#         ec.name,
#         ec.sampling_frequency,
#         ec.start_index,
#         ec.end_index,
#         StatsBase.standardize(ZScoreTransform, ec.data),
#     )
# end

function normalize_vector(v::Vector{Float64})::Vector{Float64}
    return StatsBase.standardize(ZScoreTransform, v)
end

function compute_breakpoints(n::UInt64)::Vector{Float64}
    if n < 3
        # TODO: error
        return zeros(Float64, n-1)
    end

    β = zeros(Float64, n-1)

    [β[i] = StatsFuns.norminvcdf(i / n) for i in 1:(n-1)]

    return β
end

"""
Function calulating the piecewise aggregate approximation of the ECG channel
Inputs
    - ECG Channel
    - w (number of segments for whole ECG Channel)
Outputs
    - PAA of ECG Channel
"""
# function calculate_paa(ec::ECGChannel, w::UInt64)::PAA
#     len = length(ec.data)

#     # make sure we can split data into w segments
#     if len % w != 0
#         println("N cannot be evenly divided by w")
#         return PAA(ec.name, ec.sampling_frequency, ec.start_index, ec.end_index, w, zeros(1))
#     end

#     return PAA(ec.name, ec.sampling_frequency, ec.start_index, ec.end_index, w, calculate_paa(ec.data, n_segments = w))
# end

# function calculate_paa(data::Vector{Float64}; points_per_segment::UInt64)::Vector{Float64}

#     if length(data.data) % points_per_segment != 0
#         println("data (length $(length(data))) cannot be evenly divided by points_per_segment $(signed(points_per_segment))")
#         return Vector{Float64}()
#     end

#     n_segments::UInt64 = unsigned(length(data) ÷ points_per_segment)
    
#     return calculate_paa(data, n_segments = n_segments)
# end


# returns an array ordered by segemnts which are represented as columns
function calculate_paa(data::Vector{Float64}; n_segments::UInt64, seq_len::UInt64)::Array{Float64,2}
    
    len = length(data)
    if len % n_segments != 0
        println("data (length $len) cannot be evenly divided by n_segments $(signed(n_segments))")
        return Array{Float64,2}()
    end

    if len % seq_len != 0
        println("data (length $len) cannot be evenly divided by sequence_length $(signed(seq_len))")
        return Vector{Float64}()
    end

    paa::Vector{Float64} = zeros(Float64, n_segments)
    l_by_n_segments::UInt64 = len ÷ n_segments

    for i in 1:n_segments
        paa[i] = sum(data[(l_by_n_segments*(i-1)+1):(l_by_n_segments*i)])
    end

    paa *= (n_segments / len)

    return reshape(paa, signed(seq_len), :)
end


function compute_alphabet(n::UInt64)::Vector{Char}
    if n < 3 || n > convert(UInt64, 'z')
        # TODO: error out
    end

    α::Vector{Char} = fill('a', n)
    offset::UInt64 = convert(UInt64, 'a')

    # for i in 0:(n-1)
    #     push!(alphabet, convert(Char, i + offset))
    # end

    [α[i+1] = convert(Char, i+offset) for i in 0:(n-1)]

    return α
end
