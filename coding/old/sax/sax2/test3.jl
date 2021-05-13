# test of the new plotting function
# 26.03.2021, 00:27 param

include("Structs.jl")
include("HelperFunctions.jl")

function get_ecg()
    param = Parameters(
        type = MITBIH,
        start_index = 1,
        end_index = 1_800 * 360,
        PAA_segment_count = 72,
        subsequence_length = 6,
        alphabet_size = 4,
    )

    ecg_pointer = ECGPointer(param = param, filepath = "../../ecgs/113.mit", number = 113)

    ecg = ECG(pointer = ecg_pointer, param = param, lead = II)

    z_normalize!(ecg = ecg)

    # OLD   0.120246 seconds (717 allocations: 19.825 MiB)
    # new   0.116545 seconds (713 allocations: 9.937 MiB) 

    # paa = PAA(ecg = normalized_ecg, param = param)

    # # @info paa.data

    # sax = SAX(paa = paa, ecg = normalized_ecg, param = param)

    # s1 = SAX(sax.type, sax.number, sax.lead, sax.difference_matrix, sax.data[:, 1:10_000])
    # s2 = SAX(sax.type, sax.number, sax.lead, sax.difference_matrix, sax.data[:, 10_001:20_000])

    # # min = mindist(sax1 = sax, sax2 = sax, param = param);
    # return mindist(sax1 = s1, sax2 = s2, param = param)
    return ecg
end

[@time get_ecg() for _ = 1:15];
