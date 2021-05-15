include("Parameters.jl")
include("ECG.jl")
include("SAX.jl")
include("MSAX.jl")

@inline function get_annotations(ecg::ECG, irange::UnitRange{Int64})::String
    list::Vector{String} = unique(collect(skipmissing(ecg.data[irange, end-1])))
    return string(list[sortperm(list)]...)
end

@inline function get_beat_type(ecg::ECG, irange::UnitRange{Int64})::String
    list::Vector{String} = unique(collect(skipmissing(ecg.data[irange, end])))
    return string(list[sortperm(list)]...)
end

@inline function has_special_annotation(s::Vector{String})::Bool
    return length(s) > 1
end

function get_ecg_dataframe(p::Parameters, e::ECG, k::Int64)::DataFrame

    n_sequences::Int64 = e.length ÷ p.points_per_subsequence
    n_by_l::Int64 = e.length ÷ n_sequences

    beats::Vector{String} = fill("", n_sequences)
    annotations::Vector{String} = fill("", n_sequences)
    index_range::Vector{UnitRange{Int64}} = fill((1:2)::UnitRange{Int64}, n_sequences)
    sax::Vector{Int64} = zeros(Int64, n_sequences)
    sax_dist::Vector{Float64} = zeros(Float64, n_sequences)
    msax::Vector{Int64} = zeros(Int64, n_sequences)
    msax_dist::Vector{Float64} = zeros(Float64, n_sequences)

    k_vals::Vector{Int64} = fill(k, n_sequences)
    paa::Vector{Int64} = fill(p.PAA_segment_count, n_sequences)
    subseq::Vector{Int64} = fill(p.subsequence_length, n_sequences)
    alph::Vector{Int64} = fill(p.alphabet_size, n_sequences)

    for i::Int64 ∈ 1:n_sequences
        r::UnitRange{Int64} = (n_by_l*(i-1)+1):(n_by_l*i)
        index_range[i] = r
        annotations[i] = get_annotations(e, r)
        beats[i] = get_beat_type(e, r)
    end

    return DataFrame(
        index_range = index_range,
        k = k_vals,
        paa_segments = paa,
        subsequence_count = subseq,
        alphabet_size = alph,
        annotations = annotations,
        beats = beats,
        sax = sax,
        sax_dist = sax_dist,
        msax = msax,
        msax_dist = msax_dist,
    )
end

function SAX_prepare_data!(p::Parameters, edf::DataFrame, data::Tuple{Vector{Float64},Vector{Int64}}, col::Int64)::Nothing
# function SAX_prepare_data!(p::Parameters, e::ECG, edf::DataFrame)::Nothing
    # for v::Int64 ∈ 1:e.leads
        # maxs::Vector{Float64}, inds::Vector{Int64} =
        #     HOTSAX(param = p, ecg = e, col = v)
        # ordering::Vector{Int64} = sortperm(inds)
        # maxs = maxs[ordering]
        # inds = inds[ordering]

        start_i::Int64 = 1

        for i::Int64 ∈ 1:lastindex(data[2])
            r::UnitRange{Int64} = get_subsequence_index_range(p, data[2][i])
            for j::Int64 ∈ start_i:size(edf, 1)
                if edf[j, :index_range] == r
                    start_i = j + 1
                    edf[j, :sax] += col
                    edf[j, :sax_dist] = data[1][i]
                    break
                end
            end
        end
    # end

    return nothing
end

function MSAX_prepare_data!(p::Parameters, edf::DataFrame, data::Tuple{Vector{Float64},Vector{Int64}})::Nothing
# function MSAX_prepare_data!(p::Parameters, e::ECG, edf::DataFrame)::Nothing
    # maxs::Vector{Float64}, inds::Vector{Int64} = HOTMSAX(param = p, ecg = e)
    # ordering::Vector{Int64} = sortperm(inds)
    # maxs = maxs[ordering]
    # inds = inds[ordering]

    start_i::Int64 = 1

    for i::Int64 ∈ 1:lastindex(data[2])
        r::UnitRange{Int64} = get_subsequence_index_range(p, data[2][i])
        for j::Int64 ∈ start_i:size(edf, 1)
            if edf[j, :index_range] == r
                start_i = j + 1
                edf[j, :msax] += 1
                edf[j, :msax_dist] = data[1][i]
                break
            end
        end
    end

    return nothing
end

@inline function get_k(maxs::Vector{Float64}, inds::Vector{Int64}, k::Int64)::Tuple{Vector{Float64},Vector{Int64}}
    if k < 1 || k > lastindex(inds)
        ord::Vector{Int64} = sortperm(inds)
        return maxs[ord], inds[ord]
    else
        new_m = maxs[1:k]
        new_i = inds[1:k]
        o::Vector{Int64} = sortperm(new_i)
        return new_m[o], new_i[o]
    end
end

function process_all_records(p::Parameters, subdir::String, ks::Vector{Int64})::Nothing
    directory::String = "$PROCESSED_DIR$subdir/"

    if !isdir("./$directory")
        mkpath("./$directory")
    end

    len::Int64 = length(MIT_BIH_RECORD_LIST)

    for (count::Int64, record::Int64) ∈ enumerate(MIT_BIH_RECORD_LIST)

        print("\r\027  $count/$len")
        e::ECG = get_MIT_BIH_ECG(p, record)

        sax1_maxs::Vector{Float64}, sax1_inds::Vector{Int64} = HOTSAX(param = p, ecg = e, col = 1)
        sax2_maxs::Vector{Float64}, sax2_inds::Vector{Int64} = HOTSAX(param = p, ecg = e, col = 2)

        msax_maxs::Vector{Float64}, msax_inds::Vector{Int64} = HOTMSAX(param = p, ecg = e)

        for k::Int64 ∈ ks
            filebase::String = "$directory$MIT_BIH_NAME-$(p.PAA_segment_count)-$(p.subsequence_length)-$(p.alphabet_size)-$k"

            edf::DataFrame = get_ecg_dataframe(p, e, k)

            SAX_prepare_data!(p, edf, get_k(sax1_maxs, sax1_inds, k), 1)

            SAX_prepare_data!(p, edf, get_k(sax2_maxs, sax2_inds, k), 2)

            MSAX_prepare_data!(p, edf, get_k(msax_maxs, msax_inds, k))

            CSV.write("$(filebase)_$record.$CSV_EXT", edf, quotestrings = true)
        end
    end

    println()

    return nothing
end

function test_parameters(paa::Vector{Int64}, alphabet::Vector{Int64}, ks::Vector{Int64}, path::String)::Nothing
    for paa_seg::Int64 ∈ paa
        for subseq::Int64 ∈ paa
            if paa_seg % subseq != 0
                continue
            end
            for alph::Int64 ∈ alphabet
                @info "Computing\n  paa_count=$paa_seg\n  subseg_count=$subseq\n  alphabet=$alph"
                param = Parameters(
                    PAA_segment_count = paa_seg,
                    subsequence_length = subseq,
                    alphabet_size = alph,
                    fs = MIT_BIH_FS,
                )
                process_all_records(param, path, ks)
            end
        end
    end

    return nothing
end

function test_parameters_high(paa::Vector{Int64}, alphabet::Vector{Int64}, ks::Vector{Int64}, path::String)::Nothing
    Threads.@threads for paa_seg::Int64 ∈ paa
        for subseq::Int64 ∈ paa
            if paa_seg % subseq != 0
                continue
            end
            for alph::Int64 ∈ alphabet
                @info "Computing\n  paa_count=$paa_seg\n  subseg_count=$subseq\n  alphabet=$alph"
                param = Parameters(
                    PAA_segment_count = paa_seg,
                    subsequence_length = subseq,
                    alphabet_size = alph,
                    fs = MIT_BIH_FS,
                )
                process_all_records(param, path, ks)
            end
        end
    end

    return nothing
end

function test_parameters_low(paa::Vector{Int64}, alphabet::Vector{Int64}, ks::Vector{Int64}, path::String)::Nothing
    for paa_seg::Int64 ∈ paa
        for subseq::Int64 ∈ paa
            if paa_seg % subseq != 0
                continue
            end
            Threads.@threads for alph::Int64 ∈ alphabet
                @info "Computing\n  paa_count=$paa_seg\n  subseg_count=$subseq\n  alphabet=$alph"
                param = Parameters(
                    PAA_segment_count = paa_seg,
                    subsequence_length = subseq,
                    alphabet_size = alph,
                    fs = MIT_BIH_FS,
                )
                process_all_records(param, path, ks)
            end
        end
    end

    return nothing
end

const ks = [200]
const paa = [12]
const alphabet = [9]

const subdirectory = "quick_test/"

@time test_parameters_low(paa, alphabet, ks, subdirectory)
