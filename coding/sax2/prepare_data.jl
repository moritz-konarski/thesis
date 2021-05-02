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

    for i::Int64 ∈ 1:n_sequences
        r::UnitRange{Int64} = (n_by_l*(i-1)+1):(n_by_l*i)
        index_range[i] = r
        annotations[i] = get_annotations(e, r)
        beats[i] = get_beat_type(e, r)
    end

    return DataFrame(
        index_range = index_range,
        annotations = annotations,
        beats = beats,
        sax = sax,
        sax_dist = sax_dist,
        msax = msax,
        msax_dist = msax_dist,
    )
end

function SAX_prepare_data!(p::Parameters, e::ECG, k::Int64, edf::DataFrame)::Nothing
    for v::Int64 ∈ 1:e.leads
        maxs::Vector{Float64}, inds::Vector{Int64} =
            HOTSAX(param = p, ecg = e, col = v, k = k)
        ordering::Vector{Int64} = sortperm(inds)
        maxs = maxs[ordering]
        inds = inds[ordering]

        start_i::Int64 = 1

        for i::Int64 ∈ 1:lastindex(inds)
            r::UnitRange{Int64} = get_original_index(p.points_per_subsequence, inds[i])
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

function MSAX_prepare_data!(p::Parameters, e::ECG, k::Int64, edf::DataFrame)::Nothing
    maxs::Vector{Float64}, inds::Vector{Int64} = HOTMSAX(param = p, ecg = e, k = k)
    ordering::Vector{Int64} = sortperm(inds)
    maxs = maxs[ordering]
    inds = inds[ordering]

    start_i::Int64 = 1

    for i::Int64 ∈ 1:lastindex(inds)
        r::UnitRange{Int64} = get_original_index(p.points_per_subsequence, inds[i])
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

function process_all_records(p::Parameters, k::Int64, subdir::String)::Nothing
    directory::String = "$PROCESSED_DIR$subdir/$(p.PAA_segment_count)/"
    filebase::String = "$directory$MIT_BIH_NAME-$(p.PAA_segment_count)-$(p.subsequence_length)-$(p.alphabet_size)-$k"

    if !isdir("./$directory")
        mkpath("./$directory")
    end

    for record::Int64 ∈ MIT_BIH_RECORD_LIST
        e::ECG = get_MIT_BIH_ECG(p, record)

        edf::DataFrame = get_ecg_dataframe(p, e)

        SAX_prepare_data!(p, e, k, edf)

        MSAX_prepare_data!(p, e, k, edf)

        CSV.write("$(filebase)_$record.$CSV_EXT", edf, quotestrings = true)
    end

    return nothing
end

p0 = Parameters(
    PAA_segment_count = 72,
    subsequence_length = 72,
    alphabet_size = 6,
    fs = MIT_BIH_FS,
)

p1 = Parameters(
    PAA_segment_count = 36,
    subsequence_length = 36,
    alphabet_size = 6,
    fs = MIT_BIH_FS,
)

p2 = Parameters(
    PAA_segment_count = 24,
    subsequence_length = 24,
    alphabet_size = 6,
    fs = MIT_BIH_FS,
)

p3 = Parameters(
    PAA_segment_count = 18,
    subsequence_length = 18,
    alphabet_size = 6,
    fs = MIT_BIH_FS,
)

p4 = Parameters(
    PAA_segment_count = 12,
    subsequence_length = 12,
    alphabet_size = 6,
    fs = MIT_BIH_FS,
)

p5 = Parameters(
    PAA_segment_count = 6,
    subsequence_length = 6,
    alphabet_size = 6,
    fs = MIT_BIH_FS,
)

k = Int64(80)
subdirectory = "paa_count/"

for param ∈ [p0, p1, p2, p3, p4, p5]
    process_all_records(param, k, subdirectory)
end
