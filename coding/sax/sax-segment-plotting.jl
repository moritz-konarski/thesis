"""
Main Function

Author: Moritz M. Konarski
Date: 20.03.2021

Email: konarski_m@auca.kg
GitHub: @moritz-konarski (https://github.com/moritz-konarski)
"""

include("Constants.jl")
include("ECGReader.jl")
include("PAA.jl")
include("SAX.jl")

using Plots

factor = 1
fs = 360
filepath = "../mitbih/100.mitbih"
start_index = 1
end_index = factor*720
c = I
channels = [None, I, II]
extract_channels = [false, true, false]
# w = unsigned(factor*40)
w = unsigned(factor*16)
n = unsigned(7)

p = read_csv_file(filepath, fs)

ecg = get_ECG(p, start_index, end_index, channels, extract_channels)

channel = get_ECGChannel(ecg, c)

normalized = normalize_ECGChannel(channel)

paa = calculate_paa(normalized, w)

p1 = plot(channel.data)
xlabel!(p1, "raw")

p1 = plot(normalized.data)
# xlabel!(p2, "normalized")

ys = repeat(paa.data, inner=2)

xs = zeros(Float64, length(ys))
for (i, y) in enumerate(ys)
    if i % 2 == 1
        xs[i] = (i-1) * (paa.end_index - paa.start_index) / paa.w / 2
    else
        xs[i] = (i) * (paa.end_index - paa.start_index) / paa.w / 2
    end
end

plot!(p1, xs, ys)
# plot!(p1, xs, ys, seriestype = :scatter)

ys = paa.data

xs = zeros(Float64, length(ys))
for (i, y) in enumerate(ys)
    xs[i] = (i-0.5) * (paa.end_index - paa.start_index) / paa.w
end

plot!(p1, xs, ys, seriestype = :scatter, series_annotations = text.(calculate_sax(paa, n).data, :bottom))
# ylims!(-2, 3)

# savefig("./test.png")