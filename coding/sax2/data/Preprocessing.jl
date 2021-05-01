"""
File containing the preprocessing commands for the MIT-BIH database
"""

using CSV
using Tables
using DataFrames
using Logging

if !(@isdefined DATA_FILES)
    const DATA_FILES = "data/"
    const MIT_BIH = "mit_bih/"
    const CSV_EXT = "csv"
    const DAT_EXT = "dat"
    const RECORDS_FILE = "RECORDS"
    const ANN_PREFIX = "a"
    const ANN_SUFFIX = "_ann"
    const COMPLETE_SUFFIX = "_complete"

    const WORKING_DIR = joinpath(@__DIR__, "..")
    const MIT_BIH_FILES = joinpath(WORKING_DIR, DATA_FILES, MIT_BIH)
    const MIT_BIH_RECORDS = joinpath(MIT_BIH_FILES, RECORDS_FILE)
end

"""
Takes records from `records` in `path` and converts them to csv files
"""
function records2csv(records::Vector{Int64}, path::String)

    len::Int64 = length(records)
    @info "Converting $len data files to csv"

    cd(path)

    try
        for i = 1:len
            print("\r\027  $i/$len")
            run(
                pipeline(
                    `rdsamp -r $(records[i]) -c -v -p`,
                    stdout = "$(records[i]).$CSV_EXT",
                ),
            )
        end
        println()
    catch ex
        cd(WORKING_DIR)
        rethrow(ex)
    end

    cd(WORKING_DIR)
end

"""
Takes annotation of `records` in `path` and converts them to csv files
"""
function annotations2csv(records::Vector{Int64}, path::String)

    len::Int64 = length(records)
    @info "Converting $len annotation files to csv"

    cd(path)

    try
        # this suppresses warning from the DataFrames package about missing data points in the annotations
        # this is ok because the files only contain annotations for events, and blank space indicates no annotation
        with_logger(NullLogger()) do
            for i = 1:len
                print("\r\027  $i/$len")
                filebase = "$ANN_PREFIX$(records[i])"
                run(
                    pipeline(
                        `rdann -r $(records[i]) -a atr -v`,
                        stdout = "$filebase.$DAT_EXT",
                    ),
                )
                dat2csv(filebase)
                data = DataFrame(
                    CSV.File(
                        "$filebase.$CSV_EXT",
                        normalizenames = true,
                        select = [3, 4, 8],
                        quotechar = ''',
                    ),
                )
                current_type::Union{Missing,String} = missing
                for row in eachrow(data)
                    if ismissing(row[3])
                        row[3] = current_type
                    else
                        current_type = row[3]
                    end
                end
                CSV.write("$(records[i])$ANN_SUFFIX.$CSV_EXT", data)
            end
        end
        println()
    catch ex
        cd(WORKING_DIR)
        rethrow(ex)
    end

    cd(WORKING_DIR)
end

"""
Convert a dat file to a csv file

Code adapted from https://stackoverflow.com/questions/61665998/reading-a-dat-file-in-julia-issues-with-variable-delimeter-spacing
User: StefanKarpinski
Date: April 9, 2021
"""
function dat2csv(filebase::String)
    open("$filebase.$CSV_EXT", write = true) do io
        for line in eachline("$filebase.$DAT_EXT")
            join(io, split(line, r"\s+[#]{1}\s+|\s+|\t+"), ',')
            println(io)
        end
    end
end

"""
Extract all record numbers from the RECORDS file located at `file`
"""
function get_record_numbers(file::String)::Vector{Int64}
    return (CSV.File(file, header = false)|>Tables.matrix)[:]
end

"""
Join the prepared annotation and data files into one file
"""
function join_records_and_annotations(records::Vector{Int64}, path::String)

    len::Int64 = length(records)
    @info "Joining $len annotation and record files"

    cd(path)

    try
        for i = 1:len
            print("\r\027  $i/$len")
            data = DataFrame(
                CSV.File(
                    "$(records[i]).$CSV_EXT",
                    datarow = 3,
                    drop = [1],
                    normalizenames = true,
                ),
            )
            insertcols!(data, 1, :Sample => collect(1:size(data, 1)))
            annotations = DataFrame(
                CSV.File("$(records[i])$ANN_SUFFIX.$CSV_EXT", normalizenames = true),
            )
            CSV.write(
                "$(records[i])$COMPLETE_SUFFIX.$CSV_EXT",
                outerjoin(data, annotations, on = :Sample),
            )
        end
        println()
    catch ex
        cd(WORKING_DIR)
        rethrow(ex)
    end

    cd(WORKING_DIR)
end

"""
Extract all MIT-BIH records into csv files
"""
function process_MIT_BIH_records()
    records = get_record_numbers(MIT_BIH_RECORDS)
    annotations2csv(records, MIT_BIH_FILES)
    records2csv(records, MIT_BIH_FILES)
    join_records_and_annotations(records, MIT_BIH_FILES)
end

# Extracting all the relevant MIT records
process_MIT_BIH_records()
