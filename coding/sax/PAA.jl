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
# module PAA

using StatsBase

function normalize_ECGChannel(ecg_channel::ECGChannel)::ECGChannel
    μ::Float64, σ::Float64 = mean_and_std(ecg_channel.data)
    return ECGChannel(
        ecg_channel.name,
        ecg_channel.sampling_frequency,
        ecg_channel.start_index,
        ecg_channel.end_index,
        standardize(ZScoreTransform, ecg_channel.data),
        μ,
        σ,
    )
end

function calculate_paa(ecg_channel::ECGChannel, w::UInt64)::PAA
    n = length(ecg_channel.data)
    if n % w != 0
        println("N cannot be evenly divided by w")
        exit(-1)
    end
    sum::Float64 = 0.0
    c_bar = zeros(Float64, w)
    for i = 1:w
        sum = 0.0
        for j = (n÷w*(i-1)+1):(n÷w*i)
            sum += ecg_channel.data[j]
        end
        c_bar[i] = w / n * sum
    end
    return PAA(ecg_channel.name, ecg_channel.sampling_frequency, ecg_channel.start_index, ecg_channel.end_index, w, c_bar, ecg_channel.μ, ecg_channel.σ)
end

# end #module
