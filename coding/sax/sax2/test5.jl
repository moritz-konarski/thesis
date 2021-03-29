# test of the brute force algorithm
# 26.03.2021

include("Structs.jl")
include("HelperFunctions.jl")

function sax_brute_force_discord(;
    param::Parameters,
    filepath::String,
    number::Int64,
# )::Tuple{Float64,Int64}
)

    ecg_pointer = ECGPointer(param = param, filepath = filepath, number = number)

    ecg = ECG(pointer = ecg_pointer, param = param, lead = V1)
    # ecg = ECG(pointer = ecg_pointer, param = param, lead = II)

    z_normalize!(ecg = ecg)

    # ecg = butterworth_filter(ecg = ecg, param = param)

    sax = SAX(param = param, paa = PAA(ecg = ecg, param = param))

    a, b = index_sax(sax = sax)
    # @info index_sax(sax = sax)

    @info "Brute Forcing Discord"

    best_dist::Float64 = typemin(Float64)
    best_location::Int64 = typemax(Int64)
    s = size(sax.data, 2)

    maxs = zeros(Float64, 3)
    inds = zeros(Int64, 3)

    for i = 1:s
        nearest_dist = typemax(Float64)

        for j = 1:s
            if i != j
                d = mindist(
                    segment1 = sax.data[:, i],
                    segment2 = sax.data[:, j],
                    difference_matrix = sax.difference_matrix,
                    param = param,
                )
                if d < nearest_dist
                    nearest_dist = d
                end
            end
        end

        set_d(maxs, nearest_dist, inds, i)

        # if nearest_dist > best_dist
        #     best_dist = nearest_dist
        #     best_location = i
        # end
    end

    # return best_dist, best_location
    return maxs, inds
end

function set_d(a::Vector{Float64}, v::Float64, is::Vector{Int64}, i::Int64)
    if v > a[1]
        a[2] = a[1]
        is[2] = is[1]
        a[1] = v
        is[1] = i
    elseif v > a[2]
        a[3] = a[2]
        is[3] = is[2]
        a[2] = v
        is[2] = i
    elseif v > a[3]
        a[3] = v
        is[3] = i
    end
end

# GOOD FOR 108
# PAA_segment_count = 18,
# subsequence_length = 12,
# alphabet_size = 6,

param = Parameters(
    type = MITBIH,
    # start_index = 11 * 360 + 1,
    start_index = 1,
    # start_index = 22 * 360 + 1,
    # end_index = 200 * 360,
    # end_index = 30 * 360,
    # end_index = 39 * 360,
    end_index = 5 * 360,
    # PAA_segment_count = 18,
    # subsequence_length = 12,
    # alphabet_size = 6,
    PAA_segment_count = 6,
    subsequence_length = 3,
    alphabet_size = 4,
)
filepath = "../../ecgs/108.mit"
number = 108

# [@time sax_brute_force_discord(param = param, filepath = filepath, number = number) for _ in 1:10]

d, i = sax_brute_force_discord(param = param, filepath = filepath, number = number)

@info "\nDistance is $(d[1])\nSegment $(i[1])\nIndex $((i[1]-1) * (param.type.fs ÷ param.PAA_segment_count * param.subsequence_length) + param.start_index) to $(i[1] * (param.type.fs ÷ param.PAA_segment_count * param.subsequence_length) + param.start_index)"

@info "\nDistance is $(d[2])\nSegment $(i[2])\nIndex $((i[2]-1) * (param.type.fs ÷ param.PAA_segment_count * param.subsequence_length) + param.start_index) to $(i[2] * (param.type.fs ÷ param.PAA_segment_count * param.subsequence_length) + param.start_index)"

@info "\nDistance is $(d[3])\nSegment $(i[3])\nIndex $((i[3]-1) * (param.type.fs ÷ param.PAA_segment_count * param.subsequence_length) + param.start_index) to $(i[3] * (param.type.fs ÷ param.PAA_segment_count * param.subsequence_length) + param.start_index)"

@time sax_brute_force_discord(param = param, filepath = filepath, number = number)
