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
using DataFrames
using DSP

function z_normalize(; ecg::ECG)::ECG
    if !ecg.is_normalized[1]
        @info "Z-normalizing ECG"

        μ::Float64 = mean(ecg.data)
        σ::Float64 = std(ecg.data)

        data::Matrix{Float64} = zeros(Float64, size(ecg.data))

        for i = 1:size(data, 2)
            for j = 1:size(data, 1)
                data[j, i] = (ecg.data[j, i] - μ) / σ
            end
        end

        return ECG(ecg.type, ecg.number, ecg.lead, ecg.is_filtered, [true], data)
    else
        return ecg
    end
end

function z_normalize!(; ecg::ECG)
    if !ecg.is_normalized[1]
        @info "Z-normalizing ECG"

        μ::Float64 = mean(ecg.data)
        σ::Float64 = std(ecg.data)

        for i = 1:size(ecg.data, 2)
            for j = 1:size(ecg.data, 1)
                ecg.data[j, i] = (ecg.data[j, i] - μ) / σ
            end
        end
        ecg.is_normalized[1] = true
    end
end

"""
figure out why this does not work?
"""
function butterworth_filter(; ecg::ECG, param::Parameters)::ECG

    @info "Applying Butterworth filter"

    responsetype = Highpass(0.5, fs=param.type.fs)
    designmethod = Butterworth(2)
    f = digitalfilter(responsetype, designmethod)
    data::Matrix{Float64} = filtfilt(f, ecg.data)

    return ECG(ecg.type, ecg.number, ecg.lead, [true], ecg.is_normalized, data)
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

    for i = 1:cols
        s += dist(
            chars1 = sax1.data[:, i],
            chars2 = sax2.data[:, i],
            difference_matrix = sax1.difference_matrix,
        )
    end

    return √(
        (param.end_index - param.start_index + 1) / (param.subsequence_length * cols),
    ) * √(s)
end

function dist(;
    chars1::Vector{Char},
    chars2::Vector{Char},
    difference_matrix::Matrix{Float64},
)::Float64
    s::Float64 = 0
    c = 'a' - 1

    for i = 1:length(chars1)
        s += (difference_matrix[chars1[i]-c, chars2[i]-c])^2
    end

    return s
end


function mindist(;
    segment1::Vector{Char},
    segment2::Vector{Char},
    difference_matrix::Matrix{Float64},
    param::Parameters,
)::Float64

    s = dist(chars1 = segment1, chars2 = segment2, difference_matrix = difference_matrix)

    return √(
        (param.type.fs ÷ param.PAA_segment_count * param.subsequence_length) /
        length(segment1),
    ) * √(s)
end

function index_sax(; sax::SAX)

    @info "Indexing SAX"

    unique_values = unique(sax.data, dims=2)

    @info "Counting sequences"

    counts = zeros(Int64, size(unique_values, 2))

    for i in 1:size(sax.data, 2)
        for j in 1:size(unique_values, 2)
            if sax.data[:, i] == unique_values[:, j]
                counts[j] += 1
            end
        end
    end

    return DataFrame(sequence = unique_values, count = counts)
end