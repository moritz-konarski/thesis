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

function get_ecg_dataframe(p::Parameters, e::ECG)::DataFrame

    n_sequences::Int64 = e.length ÷ p.points_per_subsequence
    n_by_l::Int64 = e.length ÷ n_sequences

    beats::Vector{String} = fill("", n_sequences)
    annotations::Vector{String} = fill("", n_sequences)
    index_range::Vector{UnitRange{Int64}} = fill((1:2)::UnitRange{Int64}, n_sequences)
    sax::Vector{Int64} = zeros(Int64, n_sequences)
    sax_dist::Vector{Float64} = zeros(Float64, n_sequences)
    msax::Vector{Int64} = zeros(Int64, n_sequences)
    msax_dist::Vector{Float64} = zeros(Float64, n_sequences)

    k_vals::Vector{Int64} = fill(p.k, n_sequences)
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

function SAX_prepare_data!(p::Parameters, e::ECG, edf::DataFrame)::Nothing
    for v::Int64 ∈ 1:e.leads
        maxs::Vector{Float64}, inds::Vector{Int64} =
            HOTSAX(param = p, ecg = e, col = v)
        ordering::Vector{Int64} = sortperm(inds)
        maxs = maxs[ordering]
        inds = inds[ordering]

        start_i::Int64 = 1

        for i::Int64 ∈ 1:lastindex(inds)
            r::UnitRange{Int64} = get_subsequence_index_range(p, inds[i])
            for j::Int64 ∈ start_i:size(edf, 1)
                if edf[j, :index_range] == r
                    start_i = j + 1
                    edf[j, :sax] += v
                    edf[j, :sax_dist] = maxs[i]
                    break
                end
            end
        end
    end

    return nothing
end

function MSAX_prepare_data!(p::Parameters, e::ECG, edf::DataFrame)::Nothing
    maxs::Vector{Float64}, inds::Vector{Int64} = HOTMSAX(param = p, ecg = e)
    ordering::Vector{Int64} = sortperm(inds)
    maxs = maxs[ordering]
    inds = inds[ordering]

    start_i::Int64 = 1

    for i::Int64 ∈ 1:lastindex(inds)
        r::UnitRange{Int64} = get_subsequence_index_range(p, inds[i])
        for j::Int64 ∈ start_i:size(edf, 1)
            if edf[j, :index_range] == r
                start_i = j + 1
                edf[j, :msax] += 1
                edf[j, :msax_dist] = maxs[i]
                break
            end
        end
    end

    return nothing
end

function process_all_records(p::Parameters, subdir::String)::Nothing
    directory::String = "$PROCESSED_DIR$subdir/"
    filebase::String = "$directory$MIT_BIH_NAME-$(p.PAA_segment_count)-$(p.subsequence_length)-$(p.alphabet_size)-$(p.k)"

    if !isdir("./$directory")
        mkpath("./$directory")
    end

    len::Int64 = length(MIT_BIH_RECORD_LIST)

    for (count::Int64, record::Int64) ∈ enumerate(MIT_BIH_RECORD_LIST)

        print("\r\027  $count/$len")
        e::ECG = get_MIT_BIH_ECG(p, record)

        edf::DataFrame = get_ecg_dataframe(p, e)

        SAX_prepare_data!(p, e, edf)

        MSAX_prepare_data!(p, e, edf)

        CSV.write("$(filebase)_$record.$CSV_EXT", edf, quotestrings = true)
    end

    println()

    return nothing
end

const subdirectory = "big_test/"

const ks =
    [-1, 1, 5, 10, 15, 20, 25, 30, 35, 40, 45, 50, 60, 70, 80, 90, 100, 125, 150, 175, 200]
const paa = [
    2,
    3,
    4,
    5,
    6,
    8,
    9,
    10,
    12,
    15,
    18,
    20,
    24,
    30,
    36,
    40,
    45,
    60,
    72,
    90,
    120,
    180,
    360,
]
const alphabet = 2:25

for k::Int64 ∈ ks
    for paa_seg::Int64 ∈ paa
        for subseq::Int64 ∈ paa
            if paa_seg % subseq != 0
                continue
            end
            for alph::Int64 ∈ alphabet
                @info "Computing\n  k=$k\n  paa_count=$paa_seg\n  subseg_count=$subseq\n  alphabet=$alph"
                param = Parameters(
                    PAA_segment_count = paa_seg,
                    subsequence_length = subseq,
                    alphabet_size = alph,
                    fs = MIT_BIH_FS,
                    k = k,
                )
                process_all_records(param, subdirectory)
            end
        end
    end
end
