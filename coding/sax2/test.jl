include("Parameters.jl")
include("ECG.jl")
include("SAX.jl")
include("MSAX.jl")

p = Parameters(
    PAA_segment_count = 12,
    subsequence_length = 6,
    alphabet_size = 4,
    fs = MIT_BIH_FS,
    # end_index = 7200
)

@time e = get_MIT_BIH_ECG(p, 213);

@time s = SAX(ecg = e, param = p);

@time si = SAX_indexing(param = p, sax = s, col = 1);

@time maxs, inds = HOTSAX(param = p, ecg = e, col = 1, k = 70);

@time m = MSAX(ecg = e, param = p);

@time mi = MSAX_indexing(param = p, msax = m);
