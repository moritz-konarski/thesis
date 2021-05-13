"""
SUMMARY
Collection of helper functions 

Author: Moritz M. Konarski
Email: konarski_m@auca.kg
GitHub: @moritz-konarski (https://github.com/moritz-konarski)
"""

# provides mean and standard deviation functions
using Statistics
# provides inverse gaussian distribution area function
using StatsFuns
# to be able to create a data structure out of heterogeneous data types
using DataFrames
# provides digital signal processing functions
using DSP
# provides the trie type
using Tries

"""
Function to z-normalize the ECG data (standard deviation = 1, mean = 0)
keyword arguments:
    - ecg: the ecg to be normalized
return type:
    - ECG

This creates a new instance of ECG. for the in-place operation, see z-normalize!
"""
function z_normalize(ecg::ECG)::ECG
    if !ecg.is_normalized[1]
        # @info "Z-normalizing ECG"

        μ::Float64 = Statistics.mean(ecg.data)
        σ::Float64 = Statistics.std(ecg.data)

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

"""
Function to z-normalize the ECG data in-place (standard deviation = 1, mean = 0)
keyword arguments:
    - ecg: the ecg to be normalized

See also z-normalize
"""
function z_normalize!(ecg::ECG)
    if !ecg.is_normalized[1]
        # @info "Z-normalizing ECG"

        μ::Float64 = Statistics.mean(ecg.data)
        σ::Float64 = Statistics.std(ecg.data)

        for i = 1:size(ecg.data, 2)
            for j = 1:size(ecg.data, 1)
                ecg.data[j, i] = (ecg.data[j, i] - μ) / σ
            end
        end
        ecg.is_normalized[1] = true
    end
end

"""
Function to compute a list of characters of length n in alphabetical order
keyword arguments:
    - alphabet_size: length of the alphabet
return type
    - list of characters
"""
function compute_alphabet(alphabet_size::UInt64)::Vector{Char}
    return fill('a', alphabet_size) .+ (0:alphabet_size-1)
end

"""
Function computing the SAX breakpoints
keyword arguments:
    - alphabet_size: how many characters are part of the alphabet
return type
    - list of break points Vector{Float64}
"""
function compute_breakpoints(alphabet_size::UInt64)::Vector{Float64}
    β = zeros(Float64, alphabet_size - 1)
    return [β[i] = StatsFuns.norminvcdf(i / alphabet_size) for i = 1:(alphabet_size-1)]
end

"""
Function for finding the distance between two SAX representations
keyword arguments:
    - sax1: first SAX representation
    - sax2: second SAX representation
    - param: parameters of the program
return type:
    - Float64, distance between the SAX sequences
"""
# function mindist(sax1::SAX, sax2::SAX; param::Parameters)::Float64

#     @info "Computing SAX Mindist"

#     if size(sax1.data) != size(sax2.data)
#         @error "Both SAX representation must have the same dimensions ($(size(sax1.data)) vs $(size(sax2.data)))"

#         throw(DomainError(size(sax1.data)))
#     end

#     cols::UInt64 = size(sax1.data, 2)

#     s::Float64 = 0.0

#     for i = 1:cols
#         s += dist(
#             sax1.data[:, i],
#             sax2.data[:, i],
#             sax1.difference_matrix,
#         )
#     end

#     return √(
#         (param.end_index - param.start_index + 1) / (param.subsequence_length * cols),
#     ) * √(s)
# end

"""
Function for the distance between two subsequences of characters
keyword arguments:
    - chars1: first sequence of characters
    - chars2: second sequence of characters
    - difference_matrix: difference matrix of the original SAX representation
return type:
    - difference between the two representations
"""
@inline function dist(
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

"""
Function to find the differences between 2 individual segments of a SAX representation 
keyword arguments:
    - segment1: the first SAX subsequence
    - segment2: the second SAX subsequence
    - difference_matrix: difference matrix of the original SAX representation
    - param: Parameters of the program
return type:
    - distance between the segments
"""
@inline function mindist(
    segment1::Vector{Char},
    segment2::Vector{Char},
    difference_matrix::Matrix{Float64},
    len::UInt64,
)::Float64

    s = dist(segment1, segment2, difference_matrix)

    return √(len / length(segment1)) * √(s)
end

"""
Function meant to index SAX representations
"""
function index_sax(sax::SAX)::Vector{UInt64}

    # @info "Indexing SAX"

    unique_sequences::Matrix{Char} = fill('_', size(sax.data))
    counts::Vector{UInt64} = zeros(UInt64, size(sax.data, 2))
    trie = Trie{Char,Vector{UInt64}}()
    last_index::UInt64 = 0

    for i::UInt64 = 1:size(sax.data, 2)
        for j = 1:size(unique_sequences, 2)
            if sax.data[:, i] == unique_sequences[:, j]
                counts[j] += 1
                try
                    push!(get(trie[sax.data[:, i]...]), i)
                catch KeyError
                    trie[sax.data[:, i]...] = [i]
                end
                break
            end
            if unique_sequences[1, j] == '_'
                last_index += 1
                unique_sequences[:, last_index] = sax.data[:, i]

                counts[last_index] += 1

                trie[sax.data[:, i]...] = [i]
                break
            end
        end
    end

    unique_sequences = unique_sequences[:, 1:last_index]
    sorter = sortperm(counts[1:last_index])

    unique_sequences = unique_sequences[:, sortperm(counts[1:last_index])]

    order = Vector{UInt64}()

    for i = 1:last_index
        order = vcat(order, get(trie[unique_sequences[:, i]...]))
    end

    return order
end

"""
Function meant to remove baseline wander from the ECG
figure out why this does not work?
"""
function butterworth_filter(ecg::ECG; param::Parameters)::ECG

    # @info "Applying Butterworth filter"

    responsetype = Highpass(0.5, fs = param.type.fs)
    designmethod = Butterworth(2)
    f = digitalfilter(responsetype, designmethod)
    data::Matrix{Float64} = filtfilt(f, ecg.data)

    return ECG(ecg.number, ecg.lead, [true], ecg.is_normalized, data)
end

@inline function set_d(
    a::Vector{Float64},
    v::Float64,
    is::Vector{Int64},
    j::Int64,
    k::UInt64,
)
    for i = 1:k
        if v > a[i]
            a[i+1:end] = a[i:end-1]
            a[i] = v

            is[i+1:end] = is[i:end-1]
            is[i] = j
            break
        end
    end
end

@inline function set_d(
    a::Vector{Float64},
    v::Float64,
    is::Vector{Int64},
    j::UInt64,
    k::UInt64,
)
    set_d(a, v, is, signed(j), k)
end

function get_beat_annotation_indices(ann::Annotation)::Vector{UInt64}
    subset::Vector{UInt64} = zeros(size(ann.data, 1))
    index::UInt64 = 0

    for i = 1:size(ann.data, 1)
        if ann.data[i, "Type"] != "N"
            index += 1
            subset[index] = i
        end
    end

    indices::Vector{UInt64} = zeros(index)
    index = 0

    for i in subset
        if i == 0
            break
        end
        if ann.data[i, "Type"] in ["V", "x", "|", "F", "A", "j"]
            index += 1
            indices[index] = ann.data[i, "Sample#"]
        end
    end

    return indices
end
