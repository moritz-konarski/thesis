"""
Main Function

Author: Moritz M. Konarski
Date: 20.03.2021

Email: konarski_m@auca.kg
GitHub: @moritz-konarski (https://github.com/moritz-konarski)
"""

include("Header.jl")
include("Helpers.jl")
include("ECGReader.jl")
include("SAX.jl")

using Plots

factor = 2
fs = 360
filepath = "../mitbih/103.mitbih"
# filepath = "../mitbih/113.mitbih"
# filepath = "../mitbih/100.mitbih"
# offset  = 11*720
# offset  = 83
offset = 602_000
start_index = offset
end_index = factor* 2 * fs + offset
c = I
d = II
channels = [None, I, II]
extract_channels = [false, true, true]
# w = unsigned(factor*40)
w = unsigned(factor*18)
# w = unsigned(factor*50)
n = unsigned(7)
s = unsigned(6)

println("read csv file")
p = read_csv_file(filepath, fs)

println("extract ECG data")
ecg = get_ECG(p, start_index, end_index, channels, extract_channels)

println("extract single channel data")
channel1 = get_ECGChannel(ecg, c)
n1 = normalize_vector(channel1.data)

# println("normalize ECG channel")
# normalized1 = normalize_ECGChannel(channel1)

# println("calulate PAA")
# paa1 = calculate_paa(normalized1, w)

# sax1 = calculate_sax(paa1, n)
sax1 = SAX(channel1, w, n, s)

println("extract single channel data")
channel2 = get_ECGChannel(ecg, d)
n2 = normalize_vector(channel2.data)

# println("normalize ECG channel")
# normalized2 = normalize_ECGChannel(channel2)

# println("calulate PAA")
# paa2 = calculate_paa(normalized2, w)

# sax2 = calculate_sax(paa2, n)

sax2 = SAX(channel2, w, n, s)

# p1 = plot(n1)
# xlabel!(p1, "raw")

println("plot normalized data")
xs = start_index:end_index
p1 = plot(xs, n1)
# xlabel!(p2, "normalized")


println("plot segments data")
ys = repeat(reshape(calculate_paa(n1, n_segments = w, seq_len = s), 1, :), inner=2)

xs = zeros(Float64, length(ys))
for (i, y) in enumerate(ys)
    if i % 2 == 1
        xs[i] = (i-1) * (end_index - start_index) / w / 2 + offset
    else
        xs[i] = (i) * (end_index - start_index) / w / 2 + offset
    end
end

plot!(p1, xs, ys)
# plot!(p1, xs, ys, seriestype = :scatter)


println("plot and calculate sax")
ys = reshape(reshape(calculate_paa(n1, n_segments = w, seq_len = s)[1], :, 1), :, 1)

xs = zeros(Float64, length(ys))
for (i, y) in enumerate(ys)
    xs[i] = (i-0.5) * (end_index - start_index) / w + offset
end

plot!(p1, xs, ys, seriestype = :scatter, series_annotations = text.(sax1.data, :bottom))

# plot!(p1, [1400; 1400], [6; -2.5], color="black", label="sax and tsax")
# plot!(p1, [1400+8*40; 1400+8*40], [6; -2.5], color="black")


# plot!(p1, [1240; 1240], [6; -2.5], color="red", label="esax")
# plot!(p1, [1240+8*40; 1240+8*40], [6; -2.5], color="red")

# plot!(p1, [1340; 1340], [6; -2.5], color="green", label="euclid")
# plot!(p1, [1340+8*40; 1340+8*40], [6; -2.5], color="green")


# # xlims!(start_index, end_index)
# # ylims!(-3.5, 6)

# # savefig("./test.png")

# println("plot normalized data")
# xs = start_index:end_index
# p2 = plot(xs, normalized2.data)
# # xlabel!(p2, "normalized")

# println("plot segments data")
# ys = repeat(paa2.data, inner=2)

# xs = zeros(Float64, length(ys))
# for (i, y) in enumerate(ys)
#     if i % 2 == 1
#         xs[i] = (i-1) * (paa2.end_index - paa2.start_index) / paa2.w / 2 + offset
#     else
#         xs[i] = (i) * (paa2.end_index - paa2.start_index) / paa2.w / 2 + offset
#     end
# end

# plot!(p2, xs, ys)
# # plot!(p1, xs, ys, seriestype = :scatter)


# println("plot and calculate sax")
# ys = paa2.data

# xs = zeros(Float64, length(ys))
# for (i, y) in enumerate(ys)
#     xs[i] = (i-0.5) * (paa2.end_index - paa2.start_index) / paa2.w + offset
# end

# plot!(p2, xs, ys, seriestype = :scatter, series_annotations = text.(sax2.data, :bottom))
# # ylims!(-3.05, 6))

# plot(p1)

# # plot(p1, p2, layout = (2, 1), labels = ["ECG" "PAA" "SAX"], title = ["MLII" "V1"])
