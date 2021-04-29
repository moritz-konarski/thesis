include("Parameters.jl")
include("ECG.jl")
include("SAX.jl")
include("MSAX.jl")

p = Parameters(
    PAA_segment_count = 18,
    subsequence_length = 12,
    alphabet_size = 6,
    fs = MIT_BIH_FS,
)

# p = Parameters(
#     PAA_segment_count = 360 ÷ 18,
#     subsequence_length = 12,
#     alphabet_size = 6,
#     fs = MIT_BIH_FS,
# )

# @time e = get_MIT_BIH_ECG(p, 108);

# # @time s = SAX(ecg = e, param = p);

# # @time si = SAX_indexing(param = p, sax = s, col = 1);

# @time maxs, inds = HOTSAX(param = p, ecg = e, col = 2, k = 70);

# @warn "Results"
# i = 1
# while maxs[i] != 0.0 && i < length(inds)
#     @info inds[i], get_original_index(segment = inds[i], points_per_segment = p.points_per_segment * p.subsequence_length)
#     global i += 1
# end

# @time m = MSAX(ecg = e, param = p);

# @time mi = MSAX_indexing(param = p, msax = m);


@time e = get_MIT_BIH_ECG(p, 108);

# @time s = SAX(ecg = e, param = p);

# @time si = SAX_indexing(param = p, sax = s, col = 1);

@time maxs, inds = HOTMSAX(param = p, ecg = e, col = 2, k = 70);

@warn "Results"
i = 1
while maxs[i] != 0.0 && i < length(inds)
    @info inds[i], get_original_index(segment = inds[i], points_per_segment = p.points_per_segment * p.subsequence_length)
    global i += 1
end