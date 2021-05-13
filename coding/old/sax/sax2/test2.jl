# test of the new plotting function
# 26.03.2021, 21:27 param

include("Structs.jl")
include("HelperFunctions.jl")
include("Plotting.jl")

function get_ecg()
    param = Parameters(
        type = MITBIH,
        start_index = 11 * 360 + 1,
        # start_index = 22*360+ 1,
        # end_index = 30 * 360,
        end_index = 39 * 360,
        PAA_segment_count = 18,
        subsequence_length = 6,
        alphabet_size = 6,
    )

    ecg_pointer = ECGPointer(param = param, filepath = "../../ecgs/108.mit", number = 108)

    ecg = ECG(pointer = ecg_pointer, param = param, lead = II)
    ecg2 = ECG(pointer = ecg_pointer, param = param, lead = V1)

    z_normalize!(ecg = ecg)
    z_normalize!(ecg = ecg2)

    # https://www.hindawi.com/journals/cmmm/2017/9295029/
    # ecg2 = butterworth_filter(ecg = ecg2, param = param)

    paa = PAA(ecg = ecg, param = param)
    paa2 = PAA(ecg = ecg2, param = param)

    # sax = SAX(ecg = ecg, paa = paa, param = param)
    # @info size(paa)
    # @info size(normalized_ecg)

    # return paa_ecg_plot(ecg = normalized_ecg, paa = paa, param=param)
    # return ecg_paa_sax_plot(ecg = ecg, paa = paa, sax = sax, param = param)

    # p1 = ecg_plot(ecg = ecg, param = param)
    # p2 = ecg_plot(ecg = ecg2, param = param)

    p1 = paa_ecg_plot(ecg = ecg, paa = paa, param = param)
    p2 = paa_ecg_plot(ecg = ecg2, paa = paa2, param = param)

    return plot(p1, p2, layout = (2, 1))
end

get_ecg()
