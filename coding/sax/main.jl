"""
Main Function

Author: Moritz M. Konarski
Date: 20.03.2021

Email: konarski_m@auca.kg
GitHub: @moritz-konarski (https://github.com/moritz-konarski)
"""


include("Constants.jl")
# include parameters file
# if !isdefined(Main, :ECGReader)
include("ECGReader.jl")
# using .ECGReader
# end
include("PAA.jl")

using Plots

# using .Constants

# # include parameters file
# if !isdefined(Main, :PAA)
#     include("PAA.jl")
#     using .PAA
# end

fs = 360
filepath = "../mitbih/100.csv.mitbih"
start_index = 1
end_index = 720
c = I
channels = [None, I, II]
extract_channels = [false, true, false]
w = unsigned(5)

p = read_csv_file(filepath, fs)

ecg = get_ECG(p, start_index, end_index, channels, extract_channels)

channel = get_ECGChannel(ecg, c)

ch = ECGChannel(I, unsigned(360), 1, 720, sin.(range(0, stop=3*pi, length=720)))

normalized = normalize_ECGChannel(ch)
# normalized = normalize_ECGChannel(channel)

paa = calculate_paa(normalized, w)

# p1 = plot(channel.data)
# xlabel!(p1, "raw")

p1 = plot(normalized.data)
xlabel!(p2, "normalized")

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

savefig("./test.png")