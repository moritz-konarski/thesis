"""
ESAX

Author: Moritz M. Konarski
Date: 20.03.2021

Email: konarski_m@auca.kg
GitHub: @moritz-konarski (https://github.com/moritz-konarski)
"""

function calculate_epaa(ecg_channel::ECGChannel, w::UInt64)::EPAA
    n = length(ecg_channel.data)
    if n % w != 0
        println("N cannot be evenly divided by w")
    end

    min_max = fill((0.0, 0.0, 0.0), n)
    min::Tuple{Float64,Int64} = (0.0, 0)
    max::Tuple{Float64,Int64} = (0.0, 0)
    mean::Tuple{Float64,Int64} = (0.0, 0)
    val::Float64 = 0
    sum::Float64 = 0

    for i = 1:w
        min = (typemax(Float64), 0)
        max = (typemin(Float64), 0)
        sum = 0.0

        for j in (n÷w*(i-1)+1):(n÷w*i)
            val = ecg_channel.data[j]
            min = (min[1] > val) ? (val, i) : min
            max = (max[1] < val) ? (val, i) : max
            sum += ecg_channel.data[j]
        end
        mean = (w / n * sum, (n÷w*(i-1)+1i + n÷w*i) ÷ 2)

        if min[2] < max[2]
            if mean[2] < min[2]
                min_max[i] = (mean[1], min[1], max[1])
            elseif mean[2] < max[2]
                min_max[i] = (min[1], mean[1], max[1])
            else
                min_max[i] = (min[1], max[1], mean[1])
            end
        else
            if mean[2] < max[2]
                min_max[i] = (mean[1], max[1], min[1])
            elseif mean[2] < min[2]
                min_max[i] = (max[1], mean[1], min[1])
            else
                min_max[i] = (max[1], min[1], mean[1])
            end
        end
    end

    return EPAA(ecg_channel.name, ecg_channel.sampling_frequency, ecg_channel.start_index, ecg_channel.end_index, w, min_max)
end

using StatsFuns

function compute_esax_breakpoints(n::UInt64)::Vector{Float64}
    if n < 3
        # TODO: error out
    end

    β = zeros(Float64, n-1)

    for i in 1:(n-1)
        β[i] = norminvcdf(i / n)
    end

    return β
end

function compute_esax_alphabet(n::UInt64)::Vector{Char}
    if n < 3 || n > convert(UInt64, 'z')
        # TODO: error out
    end

    alphabet = fill(' ', n)
    offset::UInt64 = convert(UInt64, 'a')

    for i in 0:(n-1)
        alphabet[i+1] = convert(Char, i + offset)
    end

    return alphabet
end

function calculate_esax(epaa::EPAA, n::UInt64)::ESAX

    β = compute_esax_breakpoints(n)
    alphabet = compute_esax_alphabet(n)
    alphabet_max::UInt64 = length(alphabet)
    esax = Vector{Tuple{Char,Char,Char}}()
    found::Bool = false
    esax_triple = fill('a', 3)

    for triple in epaa.data
        for (j, value) in enumerate(triple)
            found = false
            for (i, breakpoint) in enumerate(β)
                if value < breakpoint
                    esax_triple[j] = alphabet[i]
                    found = true
                    break
                end
            end
            if !found
                esax_triple[j] = alphabet[alphabet_max]
            end
        end
        push!(esax, (esax_triple[1], esax_triple[2], esax_triple[3],))
    end

    return ESAX(epaa.name, epaa.sampling_frequency, epaa.start_index, epaa.end_index, epaa.w, esax, alphabet, β)
end

