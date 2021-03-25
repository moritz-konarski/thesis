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

function z_normalize(; ecg::ECG)::ECG

    @info "Z-normalizing ECG"

    data::Matrix{Float64} = (ecg.data .- mean(ecg.data)) / std(ecg.data)

    return ECG(ecg.type, ecg.number, ecg.lead, ecg.is_filtered, true, data)
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
        @error "Both SAX representation must have the same dimensions ($(size(sax1.data)) vs $(size(sax1.data)))"

        throw(DomainError(size(sax1.data)))
    end

    cols::UInt64 = size(sax1.data)[2]

    s::Float64 = 0.0

    for i = 1:cols
        s += sum(
            dist(
                chars1 = sax1.data[:, i],
                chars2 = sax2.data[:, i],
                difference_matrix = sax1.difference_matrix,
            ) .^ 2,
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
)::Vector{Float64}
    distances::Vector{Float64} = zeros(Float64, length(chars1))

    c1::Vector{UInt64} = chars1 .- 'a' .+ 1
    c2::Vector{UInt64} = chars2 .- 'a' .+ 1

    for i = 1:length(c1)
        distances[i] = difference_matrix[c1[i], c2[i]]
    end

    return distances
end
