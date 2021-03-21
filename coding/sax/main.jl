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

fs = 360
filepath = "../mitbih/100.mitbih"
start_index = 1
end_index = 720
c = I
channels = [None, I, II]
extract_channels = [false, true, false]
w = unsigned(12)
n = unsigned(8)

p = read_csv_file(filepath, fs)

ecg = get_ECG(p, start_index, end_index, channels, extract_channels)

channel = get_ECGChannel(ecg, c)

normalized = normalize_ECGChannel(channel)

paa = calculate_paa(normalized, w)

println(compute_breakpoints(w))
println(compute_alphabet(w))

calculate_sax(paa, n)