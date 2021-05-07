# TODO: test this for faults (normalization or discretization)
struct MSAX
    database::String
    number::Int64
    data::Vector{Tuple{Int8,Int8}}
end

function MSAX(; ecg::ECG, param::Parameters)::MSAX

    # @info "Calculating MSAX"

    rows::Int64 = ecg.length ÷ param.points_per_segment
    cols::Int64 = 2
    β::Vector{Float64} = get_breakpoints(param.alphabet_size)

    msax_data::Vector{Tuple{Int8,Int8}} = fill((0, 0), rows)
    paa_data::Matrix{Float64} = zeros(Float64, rows, cols)

    normalized_ecg::Matrix{Float64} = MSAX_normalize(Matrix{Float64}(ecg.data[:, 2:3]))

    for i::Int64 ∈ 1:cols
        PAA!(paa_data, normalized_ecg[:, i], i)
    end

    first::Int8 = 0
    second::Int8 = 0

    for row::Int64 ∈ 1:rows
        first = param.alphabet_size
        second = param.alphabet_size

        for (i::Int8, βi::Float64) ∈ enumerate(β)
            if paa_data[row, 1] < βi
                first = i
                break
            end
        end
        for (i::Int8, βi::Float64) ∈ enumerate(β)
            if paa_data[row, 2] < βi
                second = i
                break
            end
        end

        msax_data[row] = (first, second)
    end

    return MSAX(ecg.database, ecg.number, msax_data)
end

function MSAX_normalize(src::Matrix{Float64})::Matrix{Float64}
    μ::Matrix{Float64} = Statistics.mean(src, dims = 1)
    Σ::Matrix{Float64} = Statistics.cov(src, dims = 1)

    return (sqrt(inv(Σ)) * (src .- μ)')'
end

@inline function MSAX_mindist(
    a::Vector{Tuple{Int8,Int8}},
    b::Vector{Tuple{Int8,Int8}},
    d::Matrix{Float64},
    T::Int64,
)::Float64
    s::Float64 = 0.0

    for n::Int64 ∈ 1:lastindex(a)
        s += (d[a[n][1], b[n][1]])^2 + (d[a[n][2], b[n][2]])^2
    end

    return √(T / size(a, 1)) * √(s)
end

function MSAX_indexing(; msax::MSAX, param::Parameters)::Vector{Int64}

    # @info "Indexing MSAX"

    subsequence_count::Int64 = length(msax.data) ÷ param.subsequence_length
    unique_sequences::Matrix{Tuple{Int8,Int8}} =
        fill((-1, -1), param.subsequence_length, subsequence_count)
    counts::Vector{Int64} = zeros(UInt64, subsequence_count)
    trie = Trie{Tuple{Int8,Int8},Vector{Int64}}()
    last_index::Int64 = 0

    for i::Int64 ∈ 1:subsequence_count
        r_start::Int64 = (i - 1) * param.subsequence_length + 1
        r_end::Int64 = i * param.subsequence_length
        r::UnitRange{Int64} = r_start:r_end

        for j::Int64 ∈ 1:subsequence_count
            if msax.data[r] == unique_sequences[:, j]
                counts[j] += 1
                try
                    push!(get(trie[msax.data[r]...]), i)
                catch KeyError
                    trie[msax.data[r]...] = [i]
                end
                break
            elseif unique_sequences[1, j] == (-1, -1)
                last_index += 1
                unique_sequences[:, last_index] = msax.data[r]

                counts[last_index] += 1

                trie[msax.data[r]...] = [i]
                break
            end
        end
    end

    unique_sequences = unique_sequences[:, 1:last_index]

    unique_sequences = unique_sequences[:, sortperm(counts[1:last_index])]

    order = Vector{Int64}()

    for i = 1:last_index
        order = vcat(order, get(trie[unique_sequences[:, i]...]))
    end

    return order
end

function HOTMSAX(; param::Parameters, ecg::ECG)::Tuple{Vector{Float64},Vector{Int64}}

    # @info "HOTMSAX"

    msax::MSAX = MSAX(ecg = ecg, param = param)

    diff::Matrix{Float64} = get_difference_matrix(param.alphabet_size)

    ordering::Vector{Int64} = MSAX_indexing(msax = msax, param = param)

    maxs::Vector{Float64} = zeros(Float64, length(msax.data))
    inds::Vector{Int64} = zeros(Int64, length(msax.data))
    index::Int64 = 0

    len::Int64 = param.points_per_segment * param.subsequence_length

    for i::Int64 ∈ ordering
        nearest_dist::Float64 = typemax(Float64)
        ri_start::Int64 = (i - 1) * param.subsequence_length + 1
        ri_end::Int64 = i * param.subsequence_length
        ri::UnitRange{Int64} = ri_start:ri_end

        for j::Int64 ∈ ordering
            if i != j
                rj_start::Int64 = (j - 1) * param.subsequence_length + 1
                rj_end::Int64 = j * param.subsequence_length
                rj::UnitRange{Int64} = rj_start:rj_end
                d::Float64 = MSAX_mindist(msax.data[ri], msax.data[rj], diff, len)
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

    ordering = reverse(sortperm(maxs))

    maxs = maxs[ordering]
    inds = inds[ordering]

    if param.k > 0 && param.k < length(maxs)
        maxs = maxs[1:param.k]
        inds = inds[1:param.k]
    end

    return maxs, inds
end
