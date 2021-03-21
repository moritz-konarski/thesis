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

const speed_factor = 7
const speed_fs = 360
const speed_filepath = "../mitbih/100.mitbih"
const speed_start_index = 1
const speed_c = I
const speed_channels = [None, I, II]
const speed_extract_channels = [false, true, false]
const speed_n = unsigned(9)
const speed_ppi = 18

function test()
    println("Test1")
    println("read_csv_file")
    @time p = read_csv_file(speed_filepath, speed_fs)

    println("w")
    @time w::UInt64 = unsigned((p.length - (p.length % speed_ppi)) ÷ speed_ppi)
    end_index::Int64 = p.length - (p.length % speed_ppi)

    println("get_ECG")
    @time ecg = get_ECG(p, speed_start_index, end_index, speed_channels, speed_extract_channels)

    println("get_ECGChannel")
    @time channel = get_ECGChannel(ecg, speed_c)

    println("normalize_ECGChannel")
    @time normalized = normalize_ECGChannel(channel)

    println("calculate_paa")
    @time paa = calculate_paa(normalized, w)

    println("calculate_sax")
    @time calculate_sax(paa, speed_n)
end

function test2()
    println("Test2")
    println("read_full_ECGChannel")
    @time channel, w = read_full_ECGChannel(speed_filepath, speed_fs, speed_extract_channels, speed_c, speed_ppi)

    println("normalize_ECGChannel")
    @time normalized = normalize_ECGChannel(channel)

    println("calculate_paa")
    @time paa = calculate_paa(normalized, w)

    println("calculate_sax")
    @time calculate_sax(paa, speed_n)
end

for i in 1:3 
    test()
end

for i in 1:3 
    test2()
end