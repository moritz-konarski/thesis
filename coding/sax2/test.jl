include("Parameters.jl")
include("ECG.jl")


p = Parameters(PAA_segment_count = 12,
    subsequence_length = 6,
    alphabet_size = 2,
    fs = MIT_BIH_FS,
)

# get_MIT_BIH_ECG(p, 100)

(@time get_MIT_BIH_ECG(p, 100));

# with copycols 0.393444 seconds (1.95 M allocations: 82.415 MiB, 33.41% gc time)
# without copycols 0.435194 seconds (1.95 M allocations: 102.252 MiB, 36.47% gc time)

# with proper type annotations and indeces 0.212648 seconds (2.71 k allocations: 33.658 MiB)