# test of the brute force algorithm
# 26.03.2021

include("Structs.jl")
include("HelperFunctions.jl")

function hot_sax(;
    param::Parameters,
    filepath::String,
    number::Int64,
    lead::ECGLead,
    k::UInt64,
# )::Tuple{Float64,Int64}
)

    ecg_pointer = ECGPointer(param = param, filepath = filepath, number = number)
    ecg = ECG(pointer = ecg_pointer, param = param, lead = lead)
    z_normalize!(ecg = ecg)
    sax = SAX(param = param, paa = PAA(ecg = ecg, param = param))
    ordering = index_sax(sax = sax)

    @info "HOT SAX"

    maxs = fill(typemin(Float64), k)
    inds = zeros(Int64, k)

    len = param.type.fs ÷ param.PAA_segment_count * param.subsequence_length

    for i in ordering
        nearest_dist = typemax(Float64)

        for j in ordering
            if i != j
                d = mindist(
                    sax.data[:, i],
                    sax.data[:, j],
                    sax.difference_matrix,
                    len,
                )
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

function sax_brute_force_discord(;
    param::Parameters,
    filepath::String,
    number::Int64,
    lead::ECGLead,
    k::UInt64,
# )::Tuple{Float64,Int64}
)

    ecg_pointer = ECGPointer(param = param, filepath = filepath, number = number)
    ecg = ECG(pointer = ecg_pointer, param = param, lead = lead)
    z_normalize!(ecg = ecg)
    sax = SAX(param = param, paa = PAA(ecg = ecg, param = param))

    @info "Brute Forcing Discord"

    best_dist::Float64 = typemin(Float64)
    best_location::Int64 = typemax(Int64)
    s = size(sax.data, 2)

    maxs = zeros(Float64, k)
    inds = zeros(Int64, k)

    len = param.type.fs ÷ param.PAA_segment_count * param.subsequence_length

    for i = 1:s
        nearest_dist = typemax(Float64)

        for j = 1:s
            if i != j
                d = mindist(
                    sax.data[:, i],
                    sax.data[:, j],
                    sax.difference_matrix,
                    len,
                )
                if d < nearest_dist
                    nearest_dist = d
                end
            end
        end

        set_d(maxs, nearest_dist, inds, i, k)
    end

    return maxs, inds
end

function set_d(a::Vector{Float64}, v::Float64, is::Vector{Int64}, i::UInt64, k::UInt64)
    set_d(a, v, is, signed(i), k)
end

function set_d(a::Vector{Float64}, v::Float64, is::Vector{Int64}, j::Int64, k::UInt64)

    # if v > last(a)
    #     for (i, x) in enumerate(reverse(a))
    #         if v < x
    #             insert!(a, i-1, v)
    #             a = a[1:l]
    #             insert!(is, i-1, j)
    #             is = is[1:l]
    #             break
    #         end
    #     end
    # end

    for i in 1:k
        if v > a[i]
            # @info length(a)
            a[i+1:end] = a[i:end-1]
            a[i] = v

            is[i+1:end] = is[i:end-1]
            is[i] = j
            # a = a[1:k]
            # insert!(is, i, j)
            # is = is[1:k]
            # @warn length(a)
            break
        end
    end

    # l = length(a)
    # println(l)


    # if v > a[1]
    #     a[2] = a[1]
    #     is[2] = is[1]
    #     a[1] = v
    #     is[1] = i
    # elseif v > a[2]
    #     a[3] = a[2]
    #     is[3] = is[2]
    #     a[2] = v
    #     is[2] = i
    # elseif v > a[3]
    #     a[3] = v
    #     is[3] = i
    # end
end

function print_results(dist, ind, param)
    seg_len = param.type.fs ÷ param.PAA_segment_count * param.subsequence_length
    offset = param.start_index
    for j in 1:length(dist)
        @info "d: $(round(dist[j], digits = 3)), s: $(ind[j]), i: $(i2s((ind[j]-1) * seg_len + offset, param)) - $(i2s((ind[j]) * seg_len + offset, param))"
    end
end

function i2s(s, param)
    return s / param.type.fs
end

# GOOD FOR 108
# PAA_segment_count = 18,
# subsequence_length = 12,
# alphabet_size = 6,

param = Parameters(
    type = MITBIH,
    start_index = 1,
    end_index = 1800 * 360,
    PAA_segment_count = 18,
    subsequence_length = 12,
    alphabet_size = 6,
)
filepath = "../../ecgs/108.mit"
number = 108
k = unsigned(5)
lead = II
# lead = V1

d, i = sax_brute_force_discord(param = param, filepath = filepath, number = number, lead = lead, k = k)
e, j = hot_sax(param = param, filepath = filepath, number = number, lead = lead, k = k)

@time d, i = sax_brute_force_discord(param = param, filepath = filepath, number = number, lead = lead, k = k)
@time e, j = hot_sax(param = param, filepath = filepath, number = number, lead = lead, k = k)

@info "Brute Force"
print_results(d, i, param)

@info "HOT SAX"
print_results(e, j, param)
