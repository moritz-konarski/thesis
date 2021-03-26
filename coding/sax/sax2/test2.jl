# test of the new plotting function
# 26.03.2021, 21:27 param

include("Structs.jl")
include("HelperFunctions.jl")
include("Plotting.jl")

function get_ecg()
    param = Parameters(
        type = MITBIH,
        start_index = 720 + 1,
        end_index = 2 * 720,
        PAA_segment_count = 12,
        subsequence_length = 3,
        alphabet_size = 4,
    )

    ecg_pointer = ECGPointer(param = param, filepath = "../../ecgs/113.mit", number = 113)

    ecg = ECG(pointer = ecg_pointer, param = param, lead = II)

    # https://www.hindawi.com/journals/cmmm/2017/9295029/
    z_normalize!(ecg = ecg)
    ecg = butterworth_filter(ecg = ecg, param = param)


    paa = PAA(ecg = ecg, param = param)

    sax = SAX(ecg = ecg, paa = paa, param = param)
    # @info size(paa)
    # @info size(normalized_ecg)

    # return paa_ecg_plot(ecg = normalized_ecg, paa = paa, param=param)
    return ecg_paa_sax_plot(ecg = ecg, paa = paa, sax = sax, param = param)
    # return ecg_plot(ecg = ecg, param = param)
end

get_ecg()
