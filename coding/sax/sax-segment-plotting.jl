"""
Main Function

Author: Moritz M. Konarski
Date: 20.03.2021

Email: konarski_m@auca.kg
GitHub: @moritz-konarski (https://github.com/moritz-konarski)
"""

include("Constants.jl")
include("ECGReader.jl")
include("Statistics.jl")
include("PAA.jl")
include("SAX.jl")

using Plots

factor = 5
fs = 360
filepath = "../mitbih/113.mitbih"
# filepath = "../mitbih/100.mitbih"
offset  = 10*720
start_index = 1 + offset
end_index = factor*720 + offset
c = I
channels = [None, I, II]
extract_channels = [false, true, false]
# w = unsigned(factor*40)
w = unsigned(factor*18)
n = unsigned(7)

println("read csv file")
p = read_csv_file(filepath, fs)

println("extract ECG data")
ecg = get_ECG(p, start_index, end_index, channels, extract_channels)

println("extract single channel data")
channel = get_ECGChannel(ecg, c)

println("normalize ECG channel")
normalized = normalize_ECGChannel(channel)

println("calulate PAA")
paa = calculate_paa(normalized, w)

sax = calculate_sax(paa, n)

# p1 = plot(channel.data)
# xlabel!(p1, "raw")

println("plot normalized data")
xs = start_index:end_index
p1 = plot(xs, normalized.data)
# xlabel!(p2, "normalized")

println("plot segments data")
ys = repeat(paa.data, inner=2)

xs = zeros(Float64, length(ys))
for (i, y) in enumerate(ys)
    if i % 2 == 1
        xs[i] = (i-1) * (paa.end_index - paa.start_index) / paa.w / 2 + offset
    else
        xs[i] = (i) * (paa.end_index - paa.start_index) / paa.w / 2 + offset
    end
end

plot!(p1, xs, ys)
# plot!(p1, xs, ys, seriestype = :scatter)


println("plot and calculate sax")
ys = paa.data

xs = zeros(Float64, length(ys))
for (i, y) in enumerate(ys)
    xs[i] = (i-0.5) * (paa.end_index - paa.start_index) / paa.w + offset
end

plot!(p1, xs, ys, seriestype = :scatter, series_annotations = text.(sax.data, :bottom))

# plot!(p1, [1400; 1400], [6; -2.5], color="black", label="sax and tsax")
# plot!(p1, [1400+8*40; 1400+8*40], [6; -2.5], color="black")


# plot!(p1, [1240; 1240], [6; -2.5], color="red", label="esax")
# plot!(p1, [1240+8*40; 1240+8*40], [6; -2.5], color="red")

# plot!(p1, [1340; 1340], [6; -2.5], color="green", label="euclid")
# plot!(p1, [1340+8*40; 1340+8*40], [6; -2.5], color="green")


# xlims!(start_index, end_index)
ylims!(-2, 6)

# savefig("./test.png")