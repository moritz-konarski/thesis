include("../Parameters.jl")
include("../ECG.jl")

param = Parameters(
    PAA_segment_count = 18,
    subsequence_length = 6,
    alphabet_size = 4,
    fs = MIT_BIH_FS,
    end_index = 7200
)

ecg = get_MIT_BIH_ECG(param, 103)

s = Symbol.(names(ecg.data)[2:3])[1]
x = 2030
r = x+1:x+360
time = true
from_zero=true
# to_export =false 
to_export = true
name = "03_ecg_ann"

title = "Lead $(strip(String(s), '_')) of $(ecg.database)/$(ecg.number)"
style = ""
if to_export
    style = "no marks, line width = 0.7pt, aucablue"
else
    style = "no marks, line width = 0.7pt, blue"
end
axis_style = "grid=both"
ylab = "milli Volt"
xlab = "samples"
ys = ecg.data[r, s]
xs = collect(r)

if time
    xlab = "seconds"
    if from_zero
        xs = collect(1:length(r)) / param.fs
    else
        xs /= param.fs
    end
end

p = Axis([
    # 0.13 -> 0.244 => 0.114
    Plots.Linear(xs, ys,style = style), 
    Plots.Node(L"\textbf{P}", 0.1, -0.14), 
    Plots.Node(L"\textbf{Q}", 0.237, -0.67), 
    Plots.Node(L"\textbf{R}", 0.277, 1.87), 
    Plots.Node(L"\textbf{S}", 0.305, -0.62), 
    Plots.Node(L"\textbf{T}", 0.55, 0.21), 
    Plots.Node(L"\textbf{U}", 0.76, -0.1), 
    Plots.Node(L"\textbf{P}", 0.97, -0.1)], 
    style = axis_style, xlabel = xlab, ylabel = ylab, title = title)

if to_export
    save("../../writing/slides/pre-defense/graphics/$name.tex", p, include_preamble = false)
else
    save("./test.pdf", p)
end