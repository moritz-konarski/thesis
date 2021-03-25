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

    normalized_ecg = z_normalize(ecg = ecg)

    paa = PAA(ecg = normalized_ecg, param = param)

    # @info paa.data

    sax = SAX(paa = paa, ecg = normalized_ecg, param = param)

    min = mindist(sax1 = sax, sax2 = sax, param = param);
    # return mindist(sax1 = sax, sax2 = sax, param = param)
end

[@time get_ecg() for _ in 1:15];
