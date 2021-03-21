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

using Statistics

function normalize_ECGChannel(ecg_channel::ECGChannel)::ECGChannel
    μ::Float64 = mean(ecg_channel.data)
    σ::Float64 = stdm(ecg_channel.data, μ)
    data::Vector{Float64} = (ecg_channel.data .- μ) ./ σ
    return ECGChannel(
        ecg_channel.name,
        ecg_channel.sampling_frequency,
        ecg_channel.start_index,
        ecg_channel.end_index,
        data,
    )
end

# we have ecg of length n
# can be represented in w dimensions
# vector c_bar
# ith element of c bar is

function calculate_paa(ecg_channel::ECGChannel, w::UInt64)::PAA
    n = length(ecg_channel.data)
    if n % w != 0
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
    return PAA(ecg_channel.name, ecg_channel.sampling_frequency, ecg_channel.start_index, ecg_channel.end_index, w, c_bar)
end

# end #module
