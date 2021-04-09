# TODO: update documentation and add header
# tuned to bivariate data

"""
Function for the correct instantiation of an ECGPointer
keyword arguments:
    - filepath: the path from the current Julia environment to the ECG file
    - number: number of the ECG from the database
    - param: the parameters of the program
Return Type:
    - ECGPointer
"""

"""
Struct for the ECG data
Fields:
    - number: number of the ECG in it's collection
    - lead: the lead of the ECG
    - is_filtered: a boolean variable indicating if the ECG is filered
    - is_normalized: a boolean variable indicating if the ECG is normalized 
    - data: a matrix holding the data values
"""
struct ECG
    database::String
    number::Int64
    is_filtered::Vector{Bool}
    is_normalized::Vector{Bool}
    data::DataFrame
end

"""
Function for the instantiation of the ECG struct
keyword arguments:
    - param: parameters of the program
    - lead: lead of the ECG file to be extracted
    - pointer: pointer to the ECG file
Return type:
    - ECG
"""
function ECG(; param::Parameters, filepath::String, number::Int64, database::String)::ECG

    @info "Extracting ECG"

    index_start = 1

    if param.start_index > 1
        index_start = param.start_index
    end

    data_point_count::UInt64 = 0

    path::String = joinpath(@__DIR__, filepath, "$number$SUFFIX.$CSV_EXT")
    
    if filesize(path) == 0
        @error "File size is 0, check filepath"

        throw(DomainError(filepath))
    end

    if param.end_index > index_start
        data = DataFrame(CSV.File(path, skipto = index_start+1, threaded = false, types = [Int64, Float64, Float64, String, String], limit = param.end_index - index_start+1), copycols = false)
    else 
        data = DataFrame(CSV.File(path, skipto = index_start+1, threaded = false, types = [Int64, Float64, Float64, String, String]), copycols = false)
    end

    ECG(database, number, [false, false], [false, false], data)
end

function get_MIT_BIH_ECG(param::Parameters, number::Int64)::ECG
    if number in MIT_BIH_RECORD_LIST
        return ECG(param = param, filepath = "$DATA_FILES$MIT_BIH", number = number, database = MIT_BIH_NAME)
    else
        @error "File number $number is not in the database!"
        throw(DomainError(number))
    end
end
