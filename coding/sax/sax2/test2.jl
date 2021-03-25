# test of the new plotting function
# 26.03.2021, 00:27 param

include("Structs.jl")
include("HelperFunctions.jl")
include("Plotting.jl")

function get_ecg()
    param = Parameters(
        type = MITBIH,
        start_index = 720 + 1,
        end_index = 3 * 720,
        PAA_segment_count = 18,
        subsequence_length = 6,
        alphabet_size = 4,
    )

    ecg_pointer = ECGPointer(param = param, filepath = "../../ecgs/113.mit", number = 113)

    ecg = ECG(pointer = ecg_pointer, param = param, lead = II)

    normalized_ecg = z_normalize(ecg = ecg)

    paa = PAA(ecg = normalized_ecg, param = param)

    sax = SAX(ecg = normalized_ecg, paa = paa, param = param)
    # @info size(paa)
    # @info size(normalized_ecg)

    # return paa_ecg_plot(ecg = normalized_ecg, paa = paa, param=param)
    return ecg_paa_sax_plot(ecg = normalized_ecg, paa = paa, sax = sax, param = param)
end

get_ecg()
