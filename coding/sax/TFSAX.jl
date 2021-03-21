"""
Main Function

Author: Moritz M. Konarski
Date: 20.03.2021

Email: konarski_m@auca.kg
GitHub: @moritz-konarski (https://github.com/moritz-konarski)
"""

function calculate_tfsax(paa::PAA, ecg_channel::ECGChannel)::TFSAX


end

function calculate_trend_distance_factor(paa::PAA, ecg_channel::ECGChannel)::Vector{Float64}

    td = zeros(Float64, length(paa.data))
    # TODO: find out if this is absolute or not
    for (i, segment) in enumerate(paa.data)
        i1::UInt64 = (i-1) * paa.w + 1
        i2::UInt64 = i * paa.w + 1

        td[i] = (ecg_channel.data[i1] - segment) - (ecg_channel.data[i2] - segment)
    end
end