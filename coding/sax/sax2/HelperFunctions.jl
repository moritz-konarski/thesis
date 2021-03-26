"""
SUMMARY
Collection of helper functions 

META-INFO
Date: 25.03.2021
Author: Moritz M. Konarski
Email: konarski_m@auca.kg
GitHub: @moritz-konarski (https://github.com/moritz-konarski)
"""

using Statistics
using StatsFuns

function z_normalize(; ecg::ECG)::ECG

    @info "Z-normalizing ECG"

    data::Matrix{Float64} = (ecg.data .- mean(ecg.data)) / std(ecg.data)

    return ECG(ecg.type, ecg.number, ecg.lead, ecg.is_filtered, true, data)
end

function z_normalize!(; ecg::ECG)

    @info "Z-normalizing ECG"

    μ::Float64 = mean(ecg.data)
    σ::Float64 = std(ecg.data)

    for i in 1:size(ecg.data, 2)
        for j in 1:size(ecg.data, 1)
            ecg.data[j, i] = (ecg.data[j, i] - μ) / σ
        end
    end

    # data::Matrix{Float64} = (ecg.data .- mean(ecg.data)) / std(ecg.data)

    # return ECG(ecg.type, ecg.number, ecg.lead, ecg.is_filtered, true, data)
end

function filter(; ecg::ECG)::ECG
    # TODO
    return ecg
end

function compute_alphabet(; alphabet_size::UInt64)::Vector{Char}
    return fill('a', alphabet_size) .+ (0:alphabet_size-1)
end

function compute_breakpoints(; alphabet_size::UInt64)::Vector{Float64}
    β = zeros(Float64, alphabet_size - 1)

    [β[i] = StatsFuns.norminvcdf(i / alphabet_size) for i = 1:(alphabet_size-1)]

    return β
end

function mindist(; sax1::SAX, sax2::SAX, param::Parameters)::Float64

    @info "Computing SAX Mindist"

    if size(sax1.data) != size(sax2.data)
        @error "Both SAX representation must have the same dimensions ($(size(sax1.data)) vs $(size(sax2.data)))"

        throw(DomainError(size(sax1.data)))
    end

    cols::UInt64 = size(sax1.data, 2)

    s::Float64 = 0.0

    # OPT
    # a = 4
    # 0.140041 seconds (170.55 k allocations: 43.164 MiB, 3.25% gc time)
    #  362.39198812678205

    # OLD
    # a = 4
    # 0.150664 seconds (230.55 k allocations: 49.877 MiB, 6.63% gc time)
    #  362.39198812678205

    for i = 1:cols
        s += dist(
                chars1 = sax1.data[:, i],
                chars2 = sax2.data[:, i],
                difference_matrix = sax1.difference_matrix,
            )
    end

    s =
        √((param.end_index - param.start_index + 1) / (param.subsequence_length * cols)) *
        √(s)
end

function dist(;
    chars1::Vector{Char},
    chars2::Vector{Char},
    difference_matrix::Matrix{Float64},
)::Float64
    c1::Vector{UInt64} = zeros(UInt64, length(chars1))
    c2::Vector{UInt64} = zeros(UInt64, length(chars1))

    for i in 1:length(chars1)
        c1[i] = chars1[i] - 'a' + 1
        c2[i] = chars2[i] - 'a' + 1
    end

    s::Float64 = 0.0

    for i = 1:length(c1)
        s += (difference_matrix[c1[i], c2[i]])^2
    end

    return s
end
