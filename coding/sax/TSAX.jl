"""
SAX

Author: Moritz M. Konarski
Date: 20.03.2021

Email: konarski_m@auca.kg
GitHub: @moritz-konarski (https://github.com/moritz-konarski)
"""

using StatsFuns

function calculate_tpaa(ecg_channel::ECGChannel, w::UInt64)::TPAA
    n = length(ecg_channel.data)
    if n % w != 0
        println("N cannot be evenly divided by w")
    end
    sum::Float64 = 0.0
    c_bar = zeros(Float64, w)
    bits = zeros(Bool, n)
    for i = 1:w
        sum = 0.0
        for j = (n÷w*(i-1)+1):(n÷w*i)
            sum += ecg_channel.data[j]
        end
        c_bar[i] = w / n * sum

        for j = (n÷w*(i-1)+1):(n÷w*i)
            bits[j] = ecg_channel.data[j] > c_bar[i]
        end
    end
    return TPAA(ecg_channel.name, ecg_channel.sampling_frequency, ecg_channel.start_index, ecg_channel.end_index, w, c_bar, bits)
end


function compute_tsax_breakpoints(n::UInt64)::Vector{Float64}
    if n < 3
        # TODO: error out
    end

    β = zeros(Float64, n-1)

    for i in 1:(n-1)
        β[i] = norminvcdf(i / n)
    end

    return β
end

function compute_tsax_alphabet(n::UInt64)::Vector{Char}
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

function calculate_tsax(tpaa::TPAA, n::UInt64)::TSAX

    β = compute_tsax_breakpoints(n)
    alphabet = compute_tsax_alphabet(n)
    alphabet_max::UInt64 = length(alphabet)
    tsax = Vector{Char}()
    found::Bool = false

    for value in tpaa.data
        found = false
        for (i, breakpoint) in enumerate(β)
            if value < breakpoint
                push!(tsax, alphabet[i])
                found = true
                break
            end
        end
        if !found
            push!(tsax, alphabet[alphabet_max])
        end
    end

    return TSAX(tpaa.name, tpaa.sampling_frequency, tpaa.start_index, tpaa.end_index, tpaa.w, tsax, tpaa.bits, alphabet, β)
end