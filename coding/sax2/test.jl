include("Parameters.jl")
include("ECG.jl")
include("SAX.jl")

p = Parameters(PAA_segment_count = 12,
    subsequence_length = 6,
    alphabet_size = 3,
    fs = MIT_BIH_FS,
)

@time e = get_MIT_BIH_ECG(p, 213)

@time s = SAX(ecg = e, param = p)
