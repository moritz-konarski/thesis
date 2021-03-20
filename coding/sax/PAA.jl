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
module PAA

# include parameters file
# if !isdefined(Main, :ECGReader)
include("ECGReader.jl")
using .ECGReader
# end

using .ECGReader
# using Statistics
#
# struct PAA

# end

function normalize_ECGChannel(ecg_channel::ECGChannel)::ECGChannel
    mean::Float64 = mean(ecg_channel.data)
    std_deviation::Float64 = stdm(ecg_channel.data, mean)
    data::Vector{Float64} = (ecg_channel.data .- mean) ./ std_deviation
    return ECGChannel(ecg_channel.channel, ecg_channel.sampling_frequency, ecg_channel.start_index, ecg_channel.end_index, data)
end

# we have ecg of length n
# can be represented in w dimensions
# vector c_bar
# ith element of c bar is

function calculate_paa(ecg_channel::ECGReader.ECGChannel, w::UInt64)::PAA
    if length(ecg_channel.data) % w != 0
        exit(-1)
    end
    sum::Float64 = 0.0
    c_bar = Vector{Float64, w}
    for i in 1:w
        sum = 0.0
        for j in (n ÷ w * (i - 1) + 1):(n ÷ w * i)
            sum += ecg.data[j]
        end
        c_bar[i] = w / n * sum
    end
    return PAA()
end

end #module
