include("Parameters.jl")
include("ECG.jl")
include("Plotting.jl")
include("SAX.jl")
include("MSAX.jl")

p = Parameters(
    PAA_segment_count = 18,
    subsequence_length = 6,
    alphabet_size = 4,
    fs = MIT_BIH_FS,
    end_index = 7200
)

e = get_MIT_BIH_ECG(p, 100)

sym = Symbol.(names(e.data)[2:3])
x = 864
r = x+1:x+360+180
# r = 1:360
time = true

s = sym[1]

p = ECG_plot(ecg = e, param = p, irange = r, lead = s, time = time)

# plot!(p, size = (300, 300), title = "")
save("../../writing/slides/pre-defense/graphics/03_ecg.pdf", p)
save("../../writing/slides/pre-defense/graphics/03_ecg.tex", p, include_preamble = false)
# savefig(p, "../../writing/slides/pre-defense/graphics/03_ecg.pdf")
# return p