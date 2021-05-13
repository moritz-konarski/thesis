include("../Parameters.jl")
include("../ECG.jl")
include("../Plotting.jl")

p = Parameters(
    PAA_segment_count = 18,
    subsequence_length = 6,
    alphabet_size = 4,
    fs = MIT_BIH_FS,
    end_index = 7200
)

e = get_MIT_BIH_ECG(p, 103)

sym = Symbol.(names(e.data)[2:3])
x = 2070
r = x+1:x+360
time = true
from_zero=true
# to_export =false 
to_export = true
name = "03_ecg"

s = sym[1]

if to_export
    p = ECG_plot(ecg = e, param = p, irange = r, lead = s, time = time, from_zero=from_zero, to_export = to_export)
    save("../../writing/slides/pre-defense/graphics/$name.tex", p, include_preamble = false)
else
    p = ECG_plot(ecg = e, param = p, irange = r, lead = s, time = time, from_zero=from_zero, to_export = to_export)
    save("./test.pdf", p)
end