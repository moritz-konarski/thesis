"""
Piecewise Aggregate Approximation for SAX Implementation

Author: Moritz M. Konarski
Date: 20.03.2021

Email: konarski_m@auca.kg
GitHub: @moritz-konarski (https://github.com/moritz-konarski)
"""

"""
Module to perform PAA
"""
# module PAA

using StatsBase

function normalize_ECGChannel(ecg_channel::ECGChannel)::ECGChannel
    return ECGChannel(
        ecg_channel.name,
        ecg_channel.sampling_frequency,
        ecg_channel.start_index,
        ecg_channel.end_index,
        standardize(ZScoreTransform, ecg_channel.data),
    )
end