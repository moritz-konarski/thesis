
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

    sax_data = zeros(Int8, rows, cols)
    paa_data = zeros(Float64, rows, cols)
    normalized_ecg = zeros(Float64, ecg.length, cols)

    for i in 1:cols
        SAX_normalize!(raw = ecg.data[:, i+1], norm = normalized_ecg[:, i])
        SAX_PAA!(src = normalized_ecg[:, i], dest = paa_data[:, i])
    end

    for col in 1:cols
        for row in 1:rows
            for (i::Int8, βi) in enumerate(β)
                if paa_data[row, col] < βi
                    sax_data[row, col] = i
                end
            end
        end
    end
    
    return SAX(ecg.database, ecg.number, sax_data)
end

function SAX_PAA!(; src::Vector{Float64}, dest::Vector{Float64})

    # @info src

    w::Int64 = length(dest)
    n::Int64 = length(src)
    n_by_w::Int64 = n ÷ w

    for i in 1:w
        dest[i] = sum(src[(n_by_w * (i - 1) + 1):(n_by_w * i)])
    end

    dest *= (w / n)

    # @info dest
end

function SAX_normalize!(; raw::Vector{Float64}, norm::Vector{Float64})
    if length(raw) == length(norm)
        μ::Float64 = Statistics.mean(raw)
        σ::Float64 = Statistics.std(raw)

        for i in 1:length(raw)
            norm[i] = (raw[i] - μ) / σ
        end
    else
        @error "Both vectors must have the same length"

        throw(DomainError(length(norm)))
    end
end