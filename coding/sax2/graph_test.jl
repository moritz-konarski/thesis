include("Parameters.jl")
include("ECG.jl")
include("Plotting.jl")
include("SAX.jl")
include("MSAX.jl")

p = Parameters(
    PAA_segment_count = 18,
    subsequence_length = 6,
    alphabet_size = 6,
    fs = MIT_BIH_FS,
    # end_index = 7200
)

e = get_MIT_BIH_ECG(p, 213)

sym = Symbol.(names(e.data)[2:3])
time = false
r = 1:720

# p1 = ECG_plot(ecg = e, param = p, irange = r, lead = sym[1], time=time)
# p2 = ECG_plot(ecg = e, param = p, irange = r, lead = sym[2], time=time)

p2 = SAX_ECG_plot(ecg = e, param = p, irange = r, lead = sym[1], time=time)
SAX_PAA_plot!(p = p2, ecg = e, param = p, irange = r, lead = sym[1], time=time)

p3 = MSAX_ECG_plot(ecg = e, param = p, irange = r, lead = sym[1], time=time)
MSAX_PAA_plot!(p = p3, ecg = e, param = p, irange = r, lead = sym[1], time=time)
# p3 = MSAX_ECG_plot(ecg = e, param = p, irange = r, lead = sym[1], time=time)

plot(p2, p3, layout = (2, 1))