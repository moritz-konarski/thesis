# test of the brute force algorithm
# 26.03.2021

include("Structs.jl")
include("HelperFunctions.jl")

function hot_sax(;
    param::Parameters,
    filepath::String,
    number::Int64,
    lead::ECGLead,
    k::UInt64,
)::Tuple{Vector{Float64},Vector{Int64}}

    ecg_pointer = ECGPointer(param = param, filepath = filepath, number = number)
    ecg = ECG(pointer = ecg_pointer, param = param, lead = lead)
    # ecg = butterworth_filter(ecg, param = param)
    z_normalize!(ecg)
    sax = SAX(param = param, paa = PAA(ecg = ecg, param = param))
    ordering = index_sax(sax)

    # @info "HOT SAX"

    maxs = fill(typemin(Float64), k)
    inds = zeros(Int64, k)

    len = param.type.fs ÷ param.PAA_segment_count * param.subsequence_length

    for i in ordering
        nearest_dist = typemax(Float64)

        for j in ordering
            if i != j
                d = mindist(sax.data[:, i], sax.data[:, j], sax.difference_matrix, len)
                if d < nearest_dist
                    nearest_dist = d
                end
                if d < last(maxs)
                    break
                end
            end
        end

        set_d(maxs, nearest_dist, inds, i, k)
    end

    return maxs, inds
end

function print_results(dist, ind, param)
    seg_len = param.type.fs ÷ param.PAA_segment_count * param.subsequence_length
    offset = param.start_index
    for j = 1:length(dist)
        @info "d: $(round(dist[j], digits = 3)), s: $(ind[j]), i: $((ind[j]-1) * seg_len + offset) - $(ind[j] * seg_len + offset)"
    end
end

# GOOD FOR 108
# PAA_segment_count = 18,
# subsequence_length = 12,
# alphabet_size = 6,

function test()

p = Parameters(
    type = MITBIH,
    start_index = 1,
    end_index = 1800 * 360,
    PAA_segment_count = 18,
    subsequence_length = 12,
    alphabet_size = 6,
)
filepath = "../../ecgs/108.mit"
annpath = "../../ecgs/ann_108-1.mit"
number = 108
k = unsigned(85)
lead1 = II
lead2 = V1

ann_p = AnnotationPointer(filepath = annpath, param = p, number = number)

a = Annotation(pointer = ann_p, param = p)

indices1 = get_beat_annotation_indices(a)

# @warn length(indices1)

best_a::Int64= 0
best_seg::Int64 = 0
best_sub::Int64 = 0
found::Int64 = 0

    for al = 3:25
        for seg in [1 2 3 4 5 6 8 9 10 12 15 18 20 24 30 36 40 45 60 72 90 120 180 360]
            for subseg in
                [1 2 3 4 5 6 8 9 10 12 15 18 20 24 30 36 40 45 60 72 90 120 180 360]
                
                if seg > 3 && subseg < 4
                    continue
                end

                if subseg > seg
                    break
                end
                @time try
                    param = Parameters(
                        type = MITBIH,
                        start_index = 1,
                        end_index = 1800 * 360,
                        PAA_segment_count = seg,
                        subsequence_length = subseg,
                        alphabet_size = al,
                    )

                    @info "al: $al seg: $seg, subseg: $subseg"

                    distances1, indices2 = hot_sax(
                        param = param,
                        filepath = filepath,
                        number = number,
                        lead = lead1,
                        k = k,
                    )
                    distances2, indices3 = hot_sax(
                        param = param,
                        filepath = filepath,
                        number = number,
                        lead = lead2,
                        k = k,
                    )

                    v10 = 0
                    len = param.type.fs ÷ param.PAA_segment_count * param.subsequence_length
                    offset = param.start_index

                    for a1 in indices1
                        last = v10
                        for a2 in indices2
                            if a1 > len * (a2 - 1) + offset && a1 < len * a2 + offset
                                v10 += 1
                            end
                        end

                        if last == v10
                            for a2 in indices3
                                if a1 > len * (a2 - 1) + offset && a1 < len * a2 + offset
                                    v10 += 1
                                end
                            end
                        end
                    end

                    @info "    $v10/$(length(indices1))"

                    if v10 > found
                        found = v10
                        best_a = al
                        best_seg = seg
                        best_sub = subseg
                    end
                catch ex
                    if ex isa InterruptException
                        break
                    else
                        @error ex
                        continue
                    end
                end
            end
        end
    end

    @warn "Best Parameters:\n alphabet = $best_a\n segments per fs = $best_seg\n subsequences =  $best_sub"
end

test()
