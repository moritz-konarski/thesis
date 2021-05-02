include("../Parameters.jl")
include("../ECG.jl")
include("../Plotting.jl")
include("../SAX.jl")

p = Parameters(
    PAA_segment_count = 18,
    subsequence_length = 6,
    alphabet_size = 4,
    fs = MIT_BIH_FS,
    end_index = 7200
)

e = get_MIT_BIH_ECG(p, 103)

sym = Symbol.(names(e.data)[2:3])
x = 2020
r = x+1:x+360
time = true
from_zero=true

s = sym[1]

p1 = SAX_ECG_plot(ecg = e, param = p, irange = r, lead = s, time = time)

SAX_PAA_plot!(
    p = p1,
    ecg = e,
    param = p,
    irange = r,
    lead = s,
    time = time,
)

savefig(p1, "../../writing/slides/pre-defense/graphics/paa_graph.pdf")
return p1