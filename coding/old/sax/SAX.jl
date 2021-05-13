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

# function SAX(paa::PAA, n::UInt64)::SAX

#     β::Vector{Float64} = compute_sax_breakpoints(n)
#     α::Vector{Char} = compute_alphabet(n)
#     sax::Vector{Char} = fill(last(α), length(paa.data))

#     for (j, d) in enumerate(paa.data)
#         for (i, βi) in enumerate(β)
#             if d < βi
#                 sax[j] = α[i]
#                 break
#             end
#         end
#     end

#     return SAX(paa, sax, α, β)
# end

function SAX(ecg::ECGChannel, n_segments::UInt64, α_size::UInt64, seq_len::UInt64)::SAX

    n_sequences::UInt64 = n_segments ÷ seq_len

    β::Vector{Float64} = compute_breakpoints(α_size)
    α::Vector{Char} = compute_alphabet(α_size)
    sax::Array{Char,2} = fill(last(α), (seq_len, n_segments))
    paa::Array{Float64,2} = calculate_paa(normalize_vector(ecg.data), n_segments = n_segments, seq_len = seq_len)

    for i in 1:n_sequences
        for j in 1:seq_len
            for (k, βk) in enumerate(β)
                if paa[i, j] < βk
                    sax[i, j] = α[k]
                    break
                end
            end
        end
    end


    # for (j, d) in enumerate(paa)
    #     for (i, βi) in enumerate(β)
    #         if d < βi
    #             sax[j] = α[i]
    #             break
    #         end
    #     end
    # end

    return SAX(ecg.name, ecg.sampling_frequency, ecg.start_index, ecg.end_index, n, β, sax)
end

"""
- give w to PAA and SAX and save each segement as a smaller vector, then we can optimize all the dist algorithms for that

- maybe sort it into array that counts how often each segment is found Tuple{Vector{Float64}, UInt64} or Tuple{Vector{Char}, UInt64}
- then create a trie of the things?
"""
