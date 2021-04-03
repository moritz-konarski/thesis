# test of the brute force algorithm
# 26.03.2021

include("Structs.jl")
include("HelperFunctions.jl")

function hot_sax(;
    param::Parameters,
    filepath::String,
    number::Int64,
    # )::Tuple{Float64,Int64}
)

    ecg_pointer = ECGPointer(param = param, filepath = filepath, number = number)
    ecg = ECG(pointer = ecg_pointer, param = param, lead = V1)
    z_normalize!(ecg = ecg)
    sax = SAX(param = param, paa = PAA(ecg = ecg, param = param))
    uniques, counts, trie = index_sax(sax = sax)

    # show(stdout, "text/plain", signed.(counts))
    # println()
    # show(stdout, "text/plain", uniques)
    # println()
    p = sortperm(counts)
    # show(stdout, "text/plain", signed.(counts[p]))
    # println()
    # show(stdout, "text/plain", uniques[:, p])
    # println()
    counts = counts[p]

    mincount = counts[1]

    uniques = uniques[:, p]
    # offset = 0

    # for i in 1:length(counts)
    #     if counts[i] > mincount
    #         offset = i
    #     end
    # end

    # show(trie)

    v = Vector{UInt64}()

    # for i in 1:offset
    for i = 1:size(uniques, 2)
        v = vcat(v, get(trie[uniques[:, i]...]))
        # println(get(trie[uniques[:, i]...]))
    end

    # v = vcat(v, shuffle(1:size(sax.data, 2)))

    @info "HOT SAX"

    maxs = fill(typemin(Float64), 3)
    inds = zeros(Int64, 3)

    # for i in iterate(v)
    #     println(i in 1:size(sax.data, 2))

    # end

    len = param.type.fs ÷ param.PAA_segment_count * param.subsequence_length

    for i in v
        nearest_dist = typemax(Float64)

        for j in v
            if i != j
                d = mindist(sax.data[:, i], sax.data[:, j], sax.difference_matrix, len)
                # if sax.data[:, i] != sax.data[:, j] && d < maxs[3]
                #     break
                # end
                if d < nearest_dist
                    nearest_dist = d
                end
                if d < last(maxs)
                    break
                end
            end
        end

        set_d(maxs, nearest_dist, inds, i)
    end

    return maxs, inds
end

function sax_brute_force_discord(;
    param::Parameters,
    filepath::String,
    number::Int64,
    # )::Tuple{Float64,Int64}
)

    ecg_pointer = ECGPointer(param = param, filepath = filepath, number = number)
    ecg = ECG(pointer = ecg_pointer, param = param, lead = V1)
    z_normalize!(ecg = ecg)
    sax = SAX(param = param, paa = PAA(ecg = ecg, param = param))

    @info "Brute Forcing Discord"

    best_dist::Float64 = typemin(Float64)
    best_location::Int64 = typemax(Int64)
    s = size(sax.data, 2)

    maxs = zeros(Float64, 3)
    inds = zeros(Int64, 3)

    len = param.type.fs ÷ param.PAA_segment_count * param.subsequence_length

    for i = 1:s
        nearest_dist = typemax(Float64)

        for j = 1:s
            if i != j
                d = mindist(sax.data[:, i], sax.data[:, j], sax.difference_matrix, len)
                if d < nearest_dist
                    nearest_dist = d
                end
            end
        end

        set_d(maxs, nearest_dist, inds, i)
    end

    return maxs, inds
end

function set_d(a::Vector{Float64}, v::Float64, is::Vector{Int64}, i::UInt64)
    set_d(a, v, is, signed(i))
end

function set_d(a::Vector{Float64}, v::Float64, is::Vector{Int64}, i::Int64)
    if v != typemax(Float64)
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
end

# GOOD FOR 108
# PAA_segment_count = 18,
# subsequence_length = 12,
# alphabet_size = 6,

param = Parameters(
    type = MITBIH,
    start_index = 11 * 360 + 1,
    # start_index = 1,
    # start_index = 22 * 360 + 1,
    # end_index = 200 * 360,
    # end_index = 30 * 360,
    end_index = 39 * 360,
    # end_index = 1800 * 360,
    # PAA_segment_count = 18,
    # subsequence_length = 12,
    # alphabet_size = 6,
    PAA_segment_count = 90,
    subsequence_length = 45,
    alphabet_size = 6,
)
filepath = "../../ecgs/113.mit"
number = 108

# [@time sax_brute_force_discord(param = param, filepath = filepath, number = number) for _ in 1:10]

d, i = sax_brute_force_discord(param = param, filepath = filepath, number = number)

@info "\nDistance is $(d[1])\nSegment $(i[1])\nIndex $((i[1]-1) * (param.type.fs ÷ param.PAA_segment_count * param.subsequence_length) + param.start_index) to $(i[1] * (param.type.fs ÷ param.PAA_segment_count * param.subsequence_length) + param.start_index)"

@info "\nDistance is $(d[2])\nSegment $(i[2])\nIndex $((i[2]-1) * (param.type.fs ÷ param.PAA_segment_count * param.subsequence_length) + param.start_index) to $(i[2] * (param.type.fs ÷ param.PAA_segment_count * param.subsequence_length) + param.start_index)"

@info "\nDistance is $(d[3])\nSegment $(i[3])\nIndex $((i[3]-1) * (param.type.fs ÷ param.PAA_segment_count * param.subsequence_length) + param.start_index) to $(i[3] * (param.type.fs ÷ param.PAA_segment_count * param.subsequence_length) + param.start_index)"

e, j = hot_sax(param = param, filepath = filepath, number = number)

@info "\nDistance is $(e[1])\nSegment $(j[1])\nIndex $((j[1]-1) * (param.type.fs ÷ param.PAA_segment_count * param.subsequence_length) + param.start_index) to $(j[1] * (param.type.fs ÷ param.PAA_segment_count * param.subsequence_length) + param.start_index)"

@info "\nDistance is $(e[2])\nSegment $(j[2])\nIndex $((j[2]-1) * (param.type.fs ÷ param.PAA_segment_count * param.subsequence_length) + param.start_index) to $(j[2] * (param.type.fs ÷ param.PAA_segment_count * param.subsequence_length) + param.start_index)"

@info "\nDistance is $(e[3])\nSegment $(j[3])\nIndex $((j[3]-1) * (param.type.fs ÷ param.PAA_segment_count * param.subsequence_length) + param.start_index) to $(j[3] * (param.type.fs ÷ param.PAA_segment_count * param.subsequence_length) + param.start_index)"

# @time sax_brute_force_discord(param = param, filepath = filepath, number = number)

# @time sax_brute_force_discord(param = param, filepath = filepath, number = number)

# @time sax_brute_force_discord(param = param, filepath = filepath, number = number)

# my approach
# 3.725890 seconds (20.93 M allocations: 2.405 GiB, 12.38% gc time)
# 2.480375 seconds (19.69 M allocations: 2.345 GiB, 5.76% gc time)
# 2.458626 seconds (19.69 M allocations: 2.345 GiB, 5.63% gc time)
# 2527, 6.51

# old approach
# 3.056438 seconds (26.22 M allocations: 3.124 GiB, 6.34% gc time)
# 3.131287 seconds (26.22 M allocations: 3.124 GiB, 6.50% gc time)
# 3.284278 seconds (26.22 M allocations: 3.124 GiB, 7.59% gc time)
# 2527, 6.51


# before optimization
# ┌ Info: 
# │ Distance is 5.366942668062441
# │ Segment 1738
# └ Index 416881 to 417121
# ┌ Info: 
# │ Distance is 4.800339454852682
# │ Segment 1879
# └ Index 450721 to 450961
# ┌ Info: 
# │ Distance is 3.902838655142541
# │ Segment 2527
# └ Index 606241 to 606481
# 2.6s, 19.03M, 2.267GB

@time d, i = sax_brute_force_discord(param = param, filepath = filepath, number = number)
@time e, j = hot_sax(param = param, filepath = filepath, number = number)
