"""
Collection of distance calculation functions

Author: Moritz M. Konarski
Date: 20.03.2021

Email: konarski_m@auca.kg
GitHub: @moritz-konarski (https://github.com/moritz-konarski)
"""

function euclidean_distance(c1::ECGChannel, c2::ECGChannel)::Float64
    @assert length(c1.data) == length(c2.data)

    diffs = zeros(Float64, length(c1.data))

    for i in 1:length(c1.data)
        diffs[i] = (c1.data[i] - c2.data[i])^2
    end

    return sqrt(sum(diffs))
end


function mindist(s1::SAX, s2::SAX)::Float64
    @assert length(s1.data) == length(s2.data)

    diffs = zeros(Float64, length(s1.data))

    for i in 1:length(s1.data)
        diffs[i] = (dist(s1.data[i], s2.data[i], s1.breakpoints))^2
    end

    return sqrt((s1.end_index - s1.start_index) * length(s1.data)) * sqrt(sum(diffs))
end

function dist(c1::Char, c2::Char, breakpoints::Vector{Float64})::Float64
    if abs(c1 - c2) <= 1
        return 0.0 
    else
        if c2 > c1
            c1, c2 = c2, c1
        end
        c1 -= 'a'
        c2 -= 'a' - 1
        return breakpoints[c1] - breakpoints[c2]
    end
end

function tightness_of_lower_bound(c1::ECGChannel, c2::ECGChannel, s1::SAX, s2::SAX)::Float64
    return euclidean_distance(c1, c2) / mindist(s1, s2)
end