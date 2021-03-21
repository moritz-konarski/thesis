"""
Electrocardiogram Reader

Author: Moritz M. Konarski
Date: 20.03.2021

Email: konarski_m@auca.kg
GitHub: @moritz-konarski (https://github.com/moritz-konarski)
"""

"""
Module containing all the constants and structs of the program
"""
# module Constants

# export ECGLead
# export ECGPointer
# export ECG
# export ECGChannel

"""
Enum for different types of ECG leads
"None" is for all array elements that are not ECG leads, but other data
(indices, timestamps, ...)
"""
@enum ECGLead begin
    None
    I
    II
    III
    aVR
    aVL
    aVF
    V1
    V2
    V3
    V4
    V5
    V6
end

"""
Struct for the basic properties of an ECG file
"""
struct ECGPointer
    filename::String
    sampling_frequency::UInt64
    length::UInt64
    channels::UInt64
end

"""
Struct for the ECG
"""
struct ECG
    sampling_frequency::UInt64
    start_index::UInt64
    end_index::UInt64
    data::Array{Float64,2}
    channels::Vector{ECGLead}
end

"""
Struct for an ECG channel
"""
struct ECGChannel
    name::ECGLead
    sampling_frequency::UInt64
    start_index::UInt64
    end_index::UInt64
    data::Vector{Float64}
end

struct PAA
    name::ECGLead
    sampling_frequency::UInt64
    start_index::UInt64
    end_index::UInt64
    w::UInt64
    data::Vector{Float64}
end

struct SAX
    name::ECGLead
    sampling_frequency::UInt64
    start_index::UInt64
    end_index::UInt64
    w::UInt64
    data::Vector{Char}
    alphabet::Vector{Char}
    breakpoints::Vector{Float64}
end


# end # module