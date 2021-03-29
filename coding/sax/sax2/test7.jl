# test of the brute force algorithm
# 26.03.2021

include("Structs.jl")
include("HelperFunctions.jl")

param = Parameters(
    type = MITBIH,
    start_index = 1,
    end_index = 1800 * 360,
    PAA_segment_count = 18,
    subsequence_length = 12,
    alphabet_size = 6,
)
filepath = "../../ecgs/ann_108.mit"
number = 108

ann_p = AnnotationPointer(filepath = filepath, param = param, number = number)

a = Annotation(pointer = ann_p, param = param)