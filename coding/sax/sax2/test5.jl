# test of the brute force algorithm
# 26.03.2021

include("Structs.jl")
include("HelperFunctions.jl")

function sax_brute_force_discord(;
    param::Parameters,
    filepath::String,
    number::Int64,
)::Tuple{Float64,Int64}

    ecg_pointer = ECGPointer(param = param, filepath = filepath, number = number)

    ecg = ECG(pointer = ecg_pointer, param = param, lead = II)

    z_normalize!(ecg = ecg)

    # ecg = butterworth_filter(ecg = ecg, param = param)

    sax = SAX(param = param, ecg = ecg, paa = PAA(ecg = ecg, param = param))

    # @info index_sax(sax = sax)

    @info "Brute Forcing Discord"

    best_dist::Float64 = typemin(Float64)
    best_location::Int64 = typemax(Int64)
    s = size(sax.data, 2)

    for i = 1:s
        nearest_dist = typemax(Float64)

        for j = 1:s
            if i != j
                d = mindist(
                    segment1 = sax.data[:, i],
                    segment2 = sax.data[:, j],
                    difference_matrix = sax.difference_matrix,
                    param = param,
                )
                if d < nearest_dist
                    nearest_dist = d
                end
            end
        end

        if nearest_dist > best_dist
            best_dist = nearest_dist
            best_location = i
        end
    end

    return best_dist, best_location
end

param = Parameters(
    type = MITBIH,
    start_index = 1,
    # end_index = 200 * 360,
    end_index = 1_800 * 360,
    PAA_segment_count = 12,
    subsequence_length = 3,
    alphabet_size = 4,
)
filepath = "../../ecgs/113.mit"
number = 113

# [@time sax_brute_force_discord(param = param, filepath = filepath, number = number) for _ in 1:10]

d, i = sax_brute_force_discord(param = param, filepath = filepath, number = number)

@info "\nDistance is $d\nSegment $i\nIndex $(i * (param.type.fs ÷ param.PAA_segment_count * param.subsequence_length))"

@time sax_brute_force_discord(param = param, filepath = filepath, number = number)
