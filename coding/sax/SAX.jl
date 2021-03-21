"""
SAX

Author: Moritz M. Konarski
Date: 20.03.2021

Email: konarski_m@auca.kg
GitHub: @moritz-konarski (https://github.com/moritz-konarski)
"""

using StatsFuns

function compute_breakpoints(n::UInt64)::Vector{Float64}
    if n < 3
        # TODO: error out
    end

    β = zeros(Float64, n-1)

    for i in 1:(n-1)
        β[i] = norminvcdf(i / n)
    end

    return β
end

function compute_alphabet(n::UInt64)::Vector{Char}
    if n < 3 || n > convert(UInt64, 'z')
        # TODO: error out
    end

    alphabet = Vector{Char}()
    offset::UInt64 = convert(UInt64, 'a')

    for i in 0:(n-1)
        push!(alphabet, convert(Char, i + offset))
    end

    return alphabet
end

function calculate_sax(paa::PAA, n::UInt64)#::SAX

    β = compute_breakpoints(n)
    alphabet = compute_alphabet(n)
    alphabet_max::UInt64 = length(alphabet)
    sax = Vector{Char}()
    found::Bool = false

    for value in paa.data
        found = false
        for (i, breakpoint) in enumerate(β)
            if value < breakpoint
                push!(sax, alphabet[i])
                found = true
                break
            end
        end
        if !found
            push!(sax, alphabet[alphabet_max])
        end
    end

    # println(sax)
    return sax
end