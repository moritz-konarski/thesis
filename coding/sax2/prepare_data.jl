include("Parameters.jl")
include("ECG.jl")
include("SAX.jl")
include("MSAX.jl")

@inline function get_annotations(ecg::ECG, irange::UnitRange{Int64})::String
    list = unique(collect(skipmissing(ecg.data[irange, end-1])))
    return string(list[sortperm(list)]...)
end

@inline function get_beat_type(ecg::ECG, irange::UnitRange{Int64})::String
    list = unique(collect(skipmissing(ecg.data[irange, end])))
    return string(list[sortperm(list)]...)
end

@inline function has_special_annotation(s::Vector{String})::Bool
    return length(s) > 1
end

function get_ecg_dataframe(p::Parameters, e::ECG)::DataFrame
    
    n_sequences::Int64 = e.length ÷ p.points_per_subsequence
    n_by_l::Int64 = e.length ÷ n_sequences

    beats = fill("", n_sequences)
    annotations = fill("", n_sequences)
    index_range = fill((1:2)::UnitRange{Int64}, n_sequences)
    sax = zeros(Int64, n_sequences)
    sax_dist = zeros(Float64, n_sequences)
    msax = zeros(Int64, n_sequences)
    msax_dist = zeros(Float64, n_sequences)

    for i in 1:n_sequences
        r = (n_by_l*(i-1)+1):(n_by_l*i)
        index_range[i] = r
        annotations[i] = get_annotations(e, r)
        beats[i] =  get_beat_type(e, r)
    end

    return DataFrame(index_range = index_range, annotations = annotations, beats = beats, sax = sax, sax_dist = sax_dist, msax = msax, msax_dist = msax_dist)
end

function SAX_prepare_data(p::Parameters, e::ECG, edf::DataFrame, k::Int64)
    for v = 1:2
        maxs, inds = HOTSAX(param = p, ecg = e, col = v, k = k)
        ordering = sortperm(inds)
        maxs = maxs[ordering]
        inds = inds[ordering]

        start_i::Int64 = 1
        
        for i in 1:lastindex(inds)
            r = get_original_index(points_per_segment = p.points_per_subsequence, segment = inds[i])
            for j in start_i:size(edf, 1)
                if edf[j, :index_range] == r
                    start_i = j + 1
                    # TODO: add v here to make clear which lead the thing came from
                    # then differentiate in error analysis
                    edf[j, :sax] += 1
                    edf[j, :sax_dist] = maxs[i]
                    break
                end
            end
        end
    end
end

function MSAX_prepare_data(p::Parameters, e::ECG, edf::DataFrame, k::Int64)
    maxs, inds = HOTMSAX(param = p, ecg = e, k = k)
    ordering = sortperm(inds)
    maxs = maxs[ordering]
    inds = inds[ordering]

    start_i::Int64 = 1
    
    for i in 1:lastindex(inds)
        r = get_original_index(points_per_segment = p.points_per_subsequence, segment = inds[i])
        for j in start_i:size(edf, 1)
            if edf[j, :index_range] == r
                start_i = j + 1
                edf[j, :msax] += 1
                edf[j, :msax_dist] = maxs[i]
                break
            end
        end
    end
end

p = Parameters(
    PAA_segment_count = 24,
    # PAA_segment_count = 18,
    subsequence_length = 24,
    # subsequence_length = 12,
    alphabet_size = 10,
    # alphabet_size = 6,
    fs = MIT_BIH_FS,
)

# k = 80
k = 150

filebase = "$PROCESSED_DIR$MIT_BIH_NAME-$(p.PAA_segment_count)-$(p.subsequence_length)-$(p.alphabet_size)-$k"

for record in MIT_BIH_RECORD_LIST

    e = get_MIT_BIH_ECG(p, record)

    edf = get_ecg_dataframe(p, e)

    SAX_prepare_data(p, e, edf, k)

    MSAX_prepare_data(p, e, edf, k)

    CSV.write("$(filebase)_$record.$CSV_EXT", edf, quotestrings=true)
end

# s = Symbol.(names(e.data)[2:3])[1]
# # r = 1:360

# time = false
# sax_result = SAX_count_special_annotations(p, e)
# msax_result = MSAX_count_special_annotations(p, e)

# # print(DataFrame(sax_result))
# # print(msax_result)

# count = 0

# for l = 1:length(sax_result[1])
#     for res in sax_result[3][l]
#         global count += 1

#         inds = Vector{Int64}()
#         v = res
#         r = v[1]-500:v[2]+500

#         for i in r
#             if !ismissing(e.data[i, end-1])
#                 # println(e.data[i, end-1])
#                 if e.data[i, end-1] != "N"
#                     # println(i)
#                     push!(inds, i)
#                 end
#             end
#         end

#         p1 = SAX_ECG_plot(ecg = e, param = p, irange = r, lead = s, time = time)
#         # SAX_PAA_plot!(p = p1, ecg = e, param = p, irange = r, lead = s, time=time, breakpoints = false)

#         sp = 5

#         plot!(p1, [v[1], v[1]], [-sp, sp], label = false, linestyle = :dot, color = :green)
#         plot!(
#             p1,
#             [v[end], v[end]],
#             [-sp, sp],
#             label = false,
#             linestyle = :dot,
#             color = :green,
#         )

#         if length(inds) != 0
#             for i in inds
#                 plot!(p1, [i, i], [-3, 3], label = "anomaly", color = :red)
#             end
#         end

#         plot!(p1, title = "SAX $count")
#         gui(p1)
#         readline()
#     end
# end

# count = 0

# for l = 1:msax_result[1]
#     global count += 1

#     inds = Vector{Int64}()
#     v = msax_result[2][l]
#     r = v[1]-500:v[2]+500

#     for i in r
#         if !ismissing(e.data[i, end-1])
#             # println(e.data[i, end-1])
#             if e.data[i, end-1] != "N"
#                 # println(i)
#                 push!(inds, i)
#             end
#         end
#     end

#     p1 = MSAX_ECG_plot(ecg = e, param = p, irange = r, lead = s, time = time)
#     # SAX_PAA_plot!(p = p1, ecg = e, param = p, irange = r, lead = s, time=time, breakpoints = false)

#     sp = 5

#     plot!(p1, [v[1], v[1]], [-sp, sp], label = false, linestyle = :dot, color = :green)
#     plot!(p1, [v[end], v[end]], [-sp, sp], label = false, linestyle = :dot, color = :green)

#     if length(inds) != 0
#         for i in inds
#             plot!(p1, [i, i], [-3, 3], label = "anomaly", color = :red)
#         end
#     end

#     plot!(p1, title = "MSAX $count")
#     gui(p1)
#     readline()
# end
