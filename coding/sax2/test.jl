include("Parameters.jl")
include("ECG.jl")
include("SAX.jl")
include("MSAX.jl")
include("Plotting.jl")

@inline function get_annotations(; ecg::ECG, irange::UnitRange{Int64})::Vector{String}
    return collect(skipmissing(ecg.data[irange, end-1]))
end

@inline function has_special_annotation(s::Vector{String})::Bool
    for ann in s
        if ann != "N"
            return true
        end
    end
    return false
end

function SAX_count_special_annotations(p::Parameters, e::ECG)

    count = zeros(Int64, 2)
    i1 = Vector{UnitRange{Int64}}()
    i2 = Vector{UnitRange{Int64}}()

    for i in 1:2
        maxs, inds = HOTSAX(param = p, ecg = e, col = i)

        for ind in inds 
            r = get_original_index(segment = ind, points_per_segment = p.points_per_subsequence)
            if has_special_annotation(get_annotations(ecg = e, irange = r))
                count[i] += 1
                if i == 1
                    push!(i1, r)
                else
                    push!(i2, r)
                end
            end
        end
    end

    return names(e.data)[2:3], count, [i1, i2]
end

function MSAX_count_special_annotations(p::Parameters, e::ECG)

    count::Int64 = 0
    i = Vector{UnitRange{Int64}}()

    maxs, inds = HOTMSAX(param = p, ecg = e)

    for ind in inds 
        r = get_original_index(segment = ind, points_per_segment = p.points_per_subsequence)
        if has_special_annotation(get_annotations(ecg = e, irange = r))
            count += 1
            push!(i, r)
        end
    end

    return count, i
end

p = Parameters(
    PAA_segment_count = 18,
    subsequence_length = 12,
    alphabet_size = 6,
    fs = MIT_BIH_FS,
)

e = get_MIT_BIH_ECG(p, 108)

s = Symbol.(names(e.data)[2:3])[1]
# r = 1:360

time =false 
sax_result = SAX_count_special_annotations(p, e)
msax_result = MSAX_count_special_annotations(p, e)

# print(DataFrame(sax_result))
# print(msax_result)

count = 0

for l in 1:length(sax_result[1])
    for res in sax_result[3][l]

        global count += 1

        inds = Vector{Int64}()
        v = res
        r = v[1]-500:v[1]+500

        for i in r
            if !ismissing(e.data[i, end-1])
                # println(e.data[i, end-1])
                if e.data[i, end-1] != "N"
                    # println(i)
                    push!(inds, i)
                end
            end
        end

        p1 = SAX_ECG_plot(ecg = e, param = p, irange = r, lead = s, time=time)
        # SAX_PAA_plot!(p = p1, ecg = e, param = p, irange = r, lead = s, time=time, breakpoints = false)

        sp = 5

        plot!(p1, [v[1], v[1]], [-sp, sp], label = false, linestyle = :dot, color = :green)
        plot!(p1, [v[end], v[end]], [-sp, sp], label = false, linestyle = :dot, color = :green)

        if length(inds) != 0
            for i in inds
                plot!(p1, [i, i], [-3, 3], label = "anomaly", color = :red)
            end
        end 

        plot!(p1, title = "SAX $count")
        gui(p1)
        readline()
    end
end

count = 0

for l in 1:msax_result[1]

        global count += 1

        inds = Vector{Int64}()
        v = msax_result[2][l]
        r = v[1]-500:v[1]+500

        for i in r
            if !ismissing(e.data[i, end-1])
                # println(e.data[i, end-1])
                if e.data[i, end-1] != "N"
                    # println(i)
                    push!(inds, i)
                end
            end
        end

        p1 = MSAX_ECG_plot(ecg = e, param = p, irange = r, lead = s, time=time)
        # SAX_PAA_plot!(p = p1, ecg = e, param = p, irange = r, lead = s, time=time, breakpoints = false)

        sp = 5

        plot!(p1, [v[1], v[1]], [-sp, sp], label = false, linestyle = :dot, color = :green)
        plot!(p1, [v[end], v[end]], [-sp, sp], label = false, linestyle = :dot, color = :green)

        if length(inds) != 0
            for i in inds
                plot!(p1, [i, i], [-3, 3], label = "anomaly", color = :red)
            end
        end 

        plot!(p1, title = "MSAX $count")
        gui(p1)
        readline()
end

































# p = Parameters(
#     PAA_segment_count = 360 ÷ 18,
#     subsequence_length = 12,
#     alphabet_size = 6,
#     fs = MIT_BIH_FS,
# )


# # @time s = SAX(ecg = e, param = p);

# # @time si = SAX_indexing(param = p, sax = s, col = 1);

# maxs1, inds1 = HOTSAX(param = p, ecg = e, col = 2)

# @info maxs == maxs1
# @info inds == inds1 

# @warn "Results"


# for i in 1:length(inds)
#     r = get_original_index(segment = inds[i], points_per_segment = p.points_per_subsequence)
#     ann = get_annotations(ecg = e, irange=  r)
#     if has_special_annotation(ann)
#         @info inds[i], r, ann
#     end
# end


# #         if !("N" in skipmissing(e.data[inds[i], end-1]))
# #             @info get_original_index(segment = inds[i], points_per_segment = p.points_per_segment * p.subsequence_length)
# #         elseif length(unique(e.data[inds[i], end-1])) > 2
# #             @info get_original_index(segment = inds[i], points_per_segment = p.points_per_segment * p.subsequence_length)
# #         end 
# #    end
# end

# @time m = MSAX(ecg = e, param = p);

# @time mi = MSAX_indexing(param = p, msax = m);

# @time e = get_MIT_BIH_ECG(p, 108);

# @time s = SAX(ecg = e, param = p);

# @time si = SAX_indexing(param = p, sax = s, col = 1);

# @time maxs, inds = HOTMSAX(param = p, ecg = e, col = 2, k = 70);

# @warn "Results"
# i = 1
# while maxs[i] != 0.0 && i < length(inds)
#     @info inds[i], get_original_index(segment = inds[i], points_per_segment = p.points_per_segment * p.subsequence_length)
#     global i += 1
# end