# TODO: update documentation and create header

using CSV
using Tables
using DataFrames
using StatsFuns
using StatsBase
using Statistics

const MIT_BIH_FS = 360
const MIT_BIH_FILELEN = 650_000
const STT_FS = 250
const MIT_BIH_NAME = "MIT-BIH Database"
const STT_NAME = "European ST-T Database"

const DATA_FILES = "data/"
const MIT_BIH = "mit_bih/"
const CSV_EXT = "csv"
const DAT_EXT = "dat"
const SUFFIX = "_complete"
const RECORDS_FILE = "RECORDS"

const WORKING_DIR = @__DIR__
const MIT_BIH_FILES = joinpath(WORKING_DIR, DATA_FILES, MIT_BIH)
const MIT_BIH_RECORD_LIST = (CSV.File(joinpath(MIT_BIH_FILES, RECORDS_FILE), header = false) |> Tables.matrix)[:] 

"""
Struct for the parameters of the program
Fields:
    - start index from where the ecg file is read
    - end index to where the ecg file is read
    - PAA segment count, number of PAA segments per sampling frequency points
    - length of each PAA subsequence, number of PAA segments per subsequence
    - alphabet size, size of the alphabet used for SAX calculation
"""
struct Parameters
    start_index::Int64
    end_index::Int64
    PAA_segment_count::Int64
    points_per_segment::Int64
    subsequence_length::Int64
    alphabet_size::Int64
    fs::Int64
end

"""
Function to correctly instantiate the Parameters struct
keyword arguments:
    - type: ECGType, type of the ECG to be used
    - start_index: start index from where the ecg file is read
    - end_index: end index to where the ecg file is read
    - paa_segment_length: PAA segment count, number of PAA segments per sampling frequency points
    - subsequence_length: length of each PAA subsequence, number of PAA segments per subsequence
    - alphabet_size: alphabet size, size of the alphabet used for SAX calculation
Return Type:
    - Parameters struct
"""
function Parameters(;
    PAA_segment_count::Int64,
    subsequence_length::Int64,
    alphabet_size::Int64,
    start_index::Int64 = -1,
    end_index::Int64 = -1,
    fs::Int64,
)::Parameters

    if start_index > 0 && end_index > 0
        if start_index >= end_index
            @error "Start index must be smaller than end index"

            throw(DomainError(start_index))
        end

        if (end_index - start_index + 1) % fs != 0
            @error "Length of selected ECG range [$start_index, $end_index] must be multiple of sampling frequency $(fs)"

            throw(DomainError(end_index - start_index + 1))
        end
    end

    if fs % PAA_segment_count != 0
        @error "PAA segment count $PAA_segment_count must evenly divide sampling frequency $(fs)"

        throw(DomainError(PAA_segment_count))
    end

    if fs % subsequence_length != 0
        @error "Subsequence length $subsequence_length must evenly divide sampling frequency $(fs)"

        throw(DomainError(subsequence_length))
    end

    if alphabet_size < 2 || alphabet_size > 25
        @error "ERROR: alphabet size $alphabet_size should be in [2, 25]"

        throw(DomainError(alphabet_size))
    end

    return Parameters(
        start_index,
        end_index,
        PAA_segment_count,
        fs ÷ PAA_segment_count,
        subsequence_length,
        alphabet_size,
        fs,
    )
end

function get_breakpoints(n::Int64)::Vector{Float64}
    β = zeros(Float64, n-1)

    [β[i] = StatsFuns.norminvcdf(i / n) for i in 1:(n-1)]

    return β
end