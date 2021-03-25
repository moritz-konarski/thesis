# test of the new Structs and helpers
# 25.03.2021, 11:02 param

include("Structs.jl")

function get_ecg()::ECG
    param = Parameters(type = MITBIH, start_index = 1, end_index = 649440, PAA_segment_count = 12, subsequence_length = 6, alphabet_size = 4)

    ecg_pointer = ECGPointer(param = param, filepath = "../../ecgs/113.mit")

    return ECG(pointer = ecg_pointer, param = param, lead = II)
end

[@time get_ecg() for _ in 1:10];