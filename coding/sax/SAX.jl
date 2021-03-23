"""
SUMMARY
Function for calculation of SAX

SOURCE
SAX and its elements adapted from 
J. Lin, E. Keogh, S. Lonardi, and B. Chiu, “A symbolic representation of time series, with implications for streaming algorithms,” in Proceedings of the 8th ACM SIGMOD workshop on Research issues in data mining and knowledge discovery  - DMKD ’03, San Diego, California, 2003, pp. 2–11, doi: 10.1145/882082.882086.

META-INFO
Date: 23.03.2021
Author: Moritz M. Konarski
Email: konarski_m@auca.kg
GitHub: @moritz-konarski (https://github.com/moritz-konarski)
"""

function SAX(paa::PAA, n::UInt64)::SAX

    β::Vector{Float64} = compute_sax_breakpoints(n)
    α::Vector{Char} = compute_alphabet(n)
    sax::Vector{Char} = fill(last(α), length(paa.data))

    for (j, d) in enumerate(paa.data)
        for (i, βi) in enumerate(β)
            if d < βi
                sax[j] = α[i]
                break
            end
        end
    end

    return SAX(paa, sax, α, β)
end
