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
    length::Int64
    leads::Int64
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
function ECG(; param::Parameters, filepath::String, number::Int64, database::String, filelen::Int64)::ECG

    @info "Extracting ECG"

    index_start = 1

    if param.start_index > 1
        index_start = param.start_index
    end

    path::String = joinpath(@__DIR__, filepath, "$number$SUFFIX.$CSV_EXT")
    
    if filesize(path) == 0
        @error "File size is 0, check filepath"

        throw(DomainError(filepath))
    end

    if param.end_index > index_start
        if (param.end_index - index_start + 1) % param.fs == 0
            data = DataFrame(CSV.File(path, skipto = index_start+1, threaded = false, types = [Int64, Float64, Float64, String, String], limit = param.end_index - index_start+1), copycols = false)
        else
            @error "Length of selected segment must be divisible by $(param.fs)"

            throw(DomainError(param.fs))
        end
    else 
        max::Int64 = filelen - filelen % param.fs
        if (max - index_start + 1) % param.fs == 0
            data = DataFrame(CSV.File(path, skipto = index_start+1, limit = max, threaded = false, types = [Int64, Float64, Float64, String, String]), copycols = false)
        else
            @error "Length of selected segment must be divisible by $(param.fs)"

            throw(DomainError(param.fs))
        end
    end

    ECG(database, number, size(data, 1), size(data, 2), data)
end

function get_MIT_BIH_ECG(param::Parameters, number::Int64)::ECG
    if number in MIT_BIH_RECORD_LIST
        return ECG(param = param, filepath = "$DATA_FILES$MIT_BIH", number = number, database = MIT_BIH_NAME, filelen = MIT_BIH_FILELEN)
    else
        @error "File number $number is not in the database!"
        throw(DomainError(number))
    end
end
