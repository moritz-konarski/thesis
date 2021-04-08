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
    leads::Vector{String,2}
    is_filtered::Vector{Bool,2}
    is_normalized::Vector{Bool,2}
    data::Vector{Matrix{Float64},2}
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
    lead_count::Int64 = 2

    path::String = joinpath(@__DIR__, filepath)

    if filesize(path) == 0
        @error "File size is 0, check filepath"

        throw(DomainError(filepath))
    else
        actual_lead_count = length(
            CSV.File(path, skipto = 3, limit = 1) |> Tables.matrix,
        )

        if lead_count != actual_lead_count
            @error "Number of leads in file: $actual_lead_count is not 2"

            throw(DomainError(filepath))
        end
    end

    lead_index = findall(x -> (x == lead), param.type.leads)

    if length(lead_index) == 0
        @error "Lead is invalid for ECGType $(pointer.type.name)"

        throw(DomainError(lead))
    elseif length(lead_index) == 1
        lead_index = lead_index[1]
    else
        @error "Multiple leads of same type for ECGType $(pointer.type.name)"

        throw(DomainError(lead))
    end

    data::Matrix{Float64} =
        CSV.File(
            pointer.filepath,
            skipto = param.start_index + 1,
            limit = param.end_index - param.start_index + 1,
            threaded = false,
            header = false,
            select = [lead_index],
        ) |> Tables.matrix

    if size(data, 1) < (param.end_index - param.start_index + 1)
        @error "End Index: $(param.end_index) must be less than file length $(size(data, 1))"

        throw(DomainError(param.end_index))
    end

    data = reshape(
        data,
        :,
        signed(
            param.PAA_segment_count * (param.end_index - param.start_index + 1) ÷
            param.type.fs ÷ param.subsequence_length,
        ),
    )

    # @info "Data matrix has the dimensions $(size(data))"

    return ECG(pointer.number, lead, [false], [false], data)
    return ECG(database, number, leads, [false, false], [false, false], data)
end