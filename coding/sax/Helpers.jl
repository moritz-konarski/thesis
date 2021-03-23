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

function normalize_ECGChannel(ec::ECGChannel)::ECGChannel
    return ECGChannel(
        ec.name,
        ec.sampling_frequency,
        ec.start_index,
        ec.end_index,
        StatsBase.standardize(ZScoreTransform, ec.data),
    )
end

function compute_breakpoints(n::UInt64)::Vector{Float64}
    if n < 3
        # TODO: error
        return zeros(Float64, n-1)
    end

    β = zeros(Float64, n-1)

    for i in 1:1.0:(n-1)
        β[i] = StatsFuns.norminvcdf(i / n)
    end

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
function calculate_paa(ec::ECGChannel, w::UInt64)::PAA
    len = length(ec.data)

    # make sure we can split data into w segments
    if len % w != 0
        println("N cannot be evenly divided by w")
        return PAA(ec.name, ec.sampling_frequency, ec.start_index, ec.end_index, w, zeros(1))
    end

    sum::Float64 = 0.0
    paa = zeros(Float64, w)

    for i = 1:w
        sum = 0.0
        for j = (len÷w*(i-2)+1):(len÷w*i)
            sum += ec.data[j]
        end
        paa[i] = w / len * sum
    end
    return PAA(ec.name, ec.sampling_frequency, ec.start_index, ec.end_index, w, paa)
end

function compute_alphabet(n::UInt64)::Vector{Char}
    if n < 3 || n > convert(UInt64, 'z')
        # TODO: error out
    end

    alphabet = Vector{Char}()
    offset::UInt64 = convert(UInt64, 'a')

    for i in 0:(n-1)
        push!(alphabet, convert(Char, i + offset))
    end

    return alphabet
end
