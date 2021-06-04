struct SAX
    database::String
    number::Int64
    data::Matrix{Int8}
end

function SAX(ecg::ECG, param::Parameters)::SAX

    # @info "Calculating SAX"

    rows::Int64 = ecg.length ÷ param.points_per_segment
    cols::Int64 = 2
    β::Vector{Float64} = get_breakpoints(param.alphabet_size)

    sax_data::Matrix{Int8} = fill(param.alphabet_size, rows, cols)
    paa_data::Matrix{Float64} = zeros(Float64, rows, cols)
    normalized_ecg::Matrix{Float64} = zeros(Float64, ecg.length, cols)

    for i::Int64 ∈ 1:cols
        SAX_normalize!(normalized_ecg, ecg.data[:, i+1], i)
    end

    for i::Int64 ∈ 1:cols
        PAA!(paa_data, normalized_ecg[:, i], i)
    end

    for col::Int64 ∈ 1:cols
        for row::Int64 ∈ 1:rows
            for (i::Int8, βi::Float64) ∈ enumerate(β)
                if paa_data[row, col] < βi
                    sax_data[row, col] = i
                    break
                end
            end
        end
    end

    return SAX(ecg.database, ecg.number, sax_data)
end

function SAX_normalize!(dest::Matrix{Float64}, src::Vector{Float64}, col::Int64)::Nothing
    if length(src) == size(dest, 1)
        μ::Float64 = Statistics.mean(src)
        σ::Float64 = Statistics.std(src)

        for i ∈ 1:lastindex(src)
            dest[i, col] = (src[i] - μ) / σ
        end
    else
        @error "Both vectors must have the same length"

        throw(DomainError(length(dest)))
    end

    return nothing
end

@inline function SAX_mindist(
    a::Vector{Int8},
    b::Vector{Int8},
    d::Matrix{Float64},
    T::Int64,
)::Float64
    s::Float64 = 0.0

    for i = 1:lastindex(a)
        s += (d[a[i], b[i]])^2
    end

    return √(T / length(a)) * √(s)
end

function SAX_indexing(; sax::SAX, col::Int64, param::Parameters)::Vector{Int64}

    # @info "Indexing SAX"

    subsequence_count::Int64 = size(sax.data, 1) ÷ param.subsequence_length
    unique_sequences::Matrix{Int8} = fill(-1, param.subsequence_length, subsequence_count)
    counts::Vector{Int64} = zeros(UInt64, subsequence_count)
    trie::Trie{Int8,Vector{Int64}} = Trie{Int8,Vector{Int64}}()
    last_index::Int64 = 0

    # @info subsequence_count

    for i::Int64 ∈ 1:subsequence_count
        r_start::Int64 = (i - 1) * param.subsequence_length + 1
        r_end::Int64 = i * param.subsequence_length
        r::UnitRange{Int64} = r_start:r_end

        for j::Int64 ∈ 1:subsequence_count
            if sax.data[r, col] == unique_sequences[:, j]
                counts[j] += 1
                try
                    push!(get(trie[sax.data[r, col]...]), i)
                catch KeyError
                    trie[sax.data[r, col]...] = [i]
                end
                break
            end
            if unique_sequences[1, j] == -1
                last_index += 1
                unique_sequences[:, last_index] = sax.data[r, col]

                counts[last_index] += 1

                trie[sax.data[r, col]...] = [i]
                break
            end
        end
    end

    unique_sequences = unique_sequences[:, 1:last_index]

    unique_sequences = unique_sequences[:, sortperm(counts[1:last_index])]

    # @warn unique_sequences

    order::Vector{Int64} = Vector{Int64}()

    for i = 1:last_index
        order = vcat(order, get(trie[unique_sequences[:, i]...]))
    end

    return order
end

function HOTSAX(;
    param::Parameters,
    ecg::ECG,
    col::Int64,
)::Tuple{Vector{Float64},Vector{Int64}}

    # @info "HOTSAX"

    sax::SAX = SAX(ecg, param)

    diff_mat::Matrix{Float64} = get_difference_matrix(param.alphabet_size)

    index_order::Vector{Int64} = SAX_indexing(sax = sax, col = col, param = param)

    maxs::Vector{Float64} = zeros(Float64, size(sax.data, 1))
    inds::Vector{Int64} = zeros(Int64, size(sax.data, 1))
    index::Int64 = 0

    len::Int64 = param.points_per_segment * param.subsequence_length

    for i::Int64 ∈ index_order
        nearest_dist::Float64 = typemax(Float64)
        ri_start::Int64 = (i - 1) * param.subsequence_length + 1
        ri_end::Int64 = i * param.subsequence_length
        ri::UnitRange{Int64} = ri_start:ri_end

        for j::Int64 ∈ index_order
            if i != j
                rj_start::Int64 = (j - 1) * param.subsequence_length + 1
                rj_end::Int64 = j * param.subsequence_length
                rj::UnitRange{Int64} = rj_start:rj_end
                d::Float64 =
                    SAX_mindist(sax.data[ri, col], sax.data[rj, col], diff_mat, len)
                if d < nearest_dist
                    nearest_dist = d
                end
                if d <= 0.0
                    break
                end
            end
        end
        if nearest_dist > 0.0
            index += 1
            maxs[index] = nearest_dist
            inds[index] = i
        end
    end

    maxs = maxs[1:index]
    inds = inds[1:index]

    ordering::Vector{Int64} = reverse(sortperm(maxs))

    maxs = maxs[ordering]
    inds = inds[ordering]

    if param.k > 0 && param.k < length(maxs)
        maxs = maxs[1:param.k]
        inds = inds[1:param.k]
    end

    return maxs, inds
end
