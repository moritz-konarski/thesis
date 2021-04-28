
struct SAX
    database::String
    number::Int64
    data::Matrix{Int8}
end

function SAX(; ecg::ECG, param::Parameters)

    @info "Calculating SAX"

    rows::Int64 = ecg.length ÷ param.points_per_segment
    cols::Int64 = 2
    β::Vector{Float64} = get_breakpoints(param.alphabet_size)

    sax_data::Matrix{Int8} = fill(param.alphabet_size, rows, cols)
    paa_data = zeros(Float64, rows, cols)
    normalized_ecg = zeros(Float64, ecg.length, cols)

    for i in 1:cols
        SAX_normalize!(src = ecg.data[:, i+1], dest = normalized_ecg, col = i)
    end

    for i in 1:cols
        PAA!(src = normalized_ecg[:, i], dest = paa_data, col = i)
    end

    for col in 1:cols
        for row in 1:rows
            for (i::Int8, βi) in enumerate(β)
                if paa_data[row, col] < βi
                    sax_data[row, col] = i
                    break
                end
            end
        end
    end
    
    return SAX(ecg.database, ecg.number, sax_data)
end

function PAA!(; src::Vector{Float64}, dest::Matrix{Float64}, col::Int64)

    w::Int64 = size(dest, 1)
    n::Int64 = length(src)
    n_by_w::Int64 = n ÷ w

    for i in 1:w
        dest[i, col] = sum(src[(n_by_w * (i - 1) + 1):(n_by_w * i)])
    end

    dest[:, col] *= (w / n)
end

function SAX_normalize!(; src::Vector{Float64}, dest::Matrix{Float64}, col::Int64)
    if length(src) == size(dest, 1)
        μ::Float64 = Statistics.mean(src)
        σ::Float64 = Statistics.std(src)

        for i in 1:length(src)
            dest[i, col] = (src[i] - μ) / σ
        end
    else
        @error "Both vectors must have the same length"

        throw(DomainError(length(dest)))
    end
end

@inline function SAX_mindist(a::Vector{Int8}, b::Vector{Int8}, d::Matrix{Float64}, T::Int64)::Float64
    s::Float64 = 0.0

    for i in 1:length(a)
        s += (d[a[i], b[i]])^2
    end

    return √(T / length(a)) * √(s)
end

function SAX_indexing(; sax::SAX, col::Int64, param::Parameters)::Vector{Int64}

    @info "Indexing SAX"

    subsequence_count::Int64 = size(sax.data, 1) ÷ param.subsequence_length
    unique_sequences::Matrix{Int8} = fill(-1, param.subsequence_length, subsequence_count)
    counts::Vector{Int64} = zeros(UInt64, subsequence_count)
    trie = Trie{Int8,Vector{Int64}}()
    last_index::Int64 = 0

    for i in 1:subsequence_count
        r = ((i-1)*param.subsequence_length + 1):(i*param.subsequence_length)
        for j in 1:subsequence_count
            if sax.data[r, col] == unique_sequences[:, j]
                counts[j] += 1
                try
                    push!(get(trie[sax.data[r, col]...]), i)
                catch KeyError
                    trie[sax.data[r, col]...] = [i]
                end
                break
            elseif unique_sequences[1, j] == -1
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

    order = Vector{Int64}()

    for i = 1:last_index
        order = vcat(order, get(trie[unique_sequences[:, i]...]))
    end

    return order
end

# TODO: find out why all the nearest_dists equal 0
function HOTSAX(;
    param::Parameters,
    ecg::ECG,
    col::Int64,
    k::Int64,
)::Tuple{Vector{Float64},Vector{Int64}}

    @info "HOTSAX"

    sax = SAX(ecg = ecg, param = param)

    diff = get_difference_matrix(param.alphabet_size)

    ordering = SAX_indexing(sax = sax, col = col, param = param)

    maxs = fill(typemin(Float64), k)
    inds = zeros(Int64, k)

    len = param.points_per_segment * param.subsequence_length
    @info len

    for i in ordering
        nearest_dist = typemax(Float64)
        ri = (i-1) * param.subsequence_length + 1 : i * param.subsequence_length

        for j in ordering
            if i != j
                rj = (j-1) * param.subsequence_length + 1 : j * param.subsequence_length
                # d = mindist(sax.data[ri, col], sax.data[rj, col], sax.difference_matrix, len)
                d = SAX_mindist(sax.data[ri, col], sax.data[rj, col], diff, len)
                if d < nearest_dist
                    nearest_dist = d
                end
                if d < last(maxs)
                    break
                end
            end
        end

        set_d(maxs, nearest_dist, inds, i, k)
    end

    return maxs, inds
end