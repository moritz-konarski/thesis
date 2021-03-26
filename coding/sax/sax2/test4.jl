# test of the ECG reading functions
# 27.03.2021, 00:27 param

include("Structs.jl")

function get_ecg()
    param = Parameters(
        type = MITBIH,
        start_index = 1,
        end_index = 2 * 360,
        # end_index = 1_800 * 360,
        PAA_segment_count = 72,
        subsequence_length = 6,
        alphabet_size = 4,
    )

    ecg_pointer = ECGPointer(param = param, filepath = "../../ecgs/113.mit", number = 113)

    ecg = ECG(pointer = ecg_pointer, param = param, lead = II);

    return ""
    # return ecg
end

[@time get_ecg() for _ in 1:10];

# OG == VER 1
# OG == VER 2

# ORIGINAL LONG
# 0.275370 seconds (332 allocations: 28.570 MiB, 5.76% gc time)
# 0.257660 seconds (332 allocations: 28.570 MiB)
# 0.256578 seconds (332 allocations: 28.570 MiB)
# 0.256191 seconds (332 allocations: 28.570 MiB)
# 0.271965 seconds (332 allocations: 28.570 MiB, 3.63% gc time)
# 0.257052 seconds (332 allocations: 28.570 MiB)
# 0.259033 seconds (332 allocations: 28.570 MiB)
# 0.268124 seconds (332 allocations: 28.570 MiB, 3.36% gc time)
# 0.264100 seconds (332 allocations: 28.570 MiB)
# 0.262500 seconds (332 allocations: 28.570 MiB)

# ORIGINAL SHORT
# 0.158947 seconds (323 allocations: 18.693 MiB)
# 0.161060 seconds (323 allocations: 18.693 MiB)
# 0.161013 seconds (323 allocations: 18.693 MiB)
# 0.171542 seconds (323 allocations: 18.693 MiB)
# 0.176818 seconds (323 allocations: 18.693 MiB, 7.59% gc time)
# 0.158779 seconds (323 allocations: 18.693 MiB)
# 0.159509 seconds (323 allocations: 18.693 MiB)
# 0.164441 seconds (323 allocations: 18.693 MiB)
# 0.181676 seconds (323 allocations: 18.693 MiB, 5.50% gc time)
# 0.163999 seconds (323 allocations: 18.693 MiB)

# VER 1 LONG
# 0.199457 seconds (405 allocations: 16.146 MiB)
# 0.200750 seconds (405 allocations: 16.146 MiB)
# 0.203727 seconds (405 allocations: 16.146 MiB)
# 0.204340 seconds (405 allocations: 16.146 MiB)
# 0.202938 seconds (405 allocations: 16.146 MiB)
# 0.221462 seconds (405 allocations: 16.146 MiB, 6.67% gc time)
# 0.203750 seconds (405 allocations: 16.146 MiB)
# 0.206281 seconds (405 allocations: 16.146 MiB)
# 0.203503 seconds (405 allocations: 16.146 MiB)
# 0.203094 seconds (405 allocations: 16.146 MiB)

# VER 1 SHORT
# 0.103126 seconds (396 allocations: 6.269 MiB)
# 0.101613 seconds (396 allocations: 6.269 MiB)
# 0.103422 seconds (396 allocations: 6.269 MiB)
# 0.102740 seconds (396 allocations: 6.269 MiB)
# 0.102305 seconds (396 allocations: 6.269 MiB)
# 0.101702 seconds (396 allocations: 6.269 MiB)
# 0.124065 seconds (396 allocations: 6.269 MiB, 15.66% gc time)
# 0.103157 seconds (396 allocations: 6.269 MiB)
# 0.102396 seconds (396 allocations: 6.269 MiB)
# 0.103836 seconds (396 allocations: 6.269 MiB)

# VER 2 LONG
# 0.098335 seconds (277 allocations: 9.915 MiB)
# 0.099305 seconds (277 allocations: 9.915 MiB)
# 0.100031 seconds (277 allocations: 9.915 MiB)
# 0.099534 seconds (277 allocations: 9.915 MiB)
# 0.099261 seconds (277 allocations: 9.915 MiB)
# 0.099747 seconds (277 allocations: 9.915 MiB)
# 0.118639 seconds (277 allocations: 9.915 MiB, 14.63% gc time)
# 0.100588 seconds (277 allocations: 9.915 MiB)
# 0.100031 seconds (277 allocations: 9.915 MiB)
# 0.099244 seconds (277 allocations: 9.915 MiB)

# VER 2 SHORT
# 0.000768 seconds (268 allocations: 39.141 KiB)
# 0.000621 seconds (268 allocations: 39.141 KiB)
# 0.000693 seconds (268 allocations: 39.141 KiB)
# 0.000669 seconds (268 allocations: 39.141 KiB)
# 0.000667 seconds (268 allocations: 39.141 KiB)
# 0.000748 seconds (268 allocations: 39.141 KiB)
# 0.000645 seconds (268 allocations: 39.141 KiB)
# 0.000520 seconds (268 allocations: 39.141 KiB)
# 0.000576 seconds (268 allocations: 39.141 KiB)
# 0.000560 seconds (268 allocations: 39.141 KiB)