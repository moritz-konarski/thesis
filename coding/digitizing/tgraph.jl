using CSV, Tables, Plots, Interpolations, StatsBase, DataFrames

f1 = "./scans/070bpm-v3"
f4 = "./scans/097bpm-v3"

N_interpolation_points = Int64(19 * 1//5 * 500)

path = f1
data = CSV.File("$path.csv") |> Tables.matrix

dmax = maximum(data[:, 1])
dmin = minimum(data[:, 1])
nodes = (data[:, 1],)

i = interpolate(nodes, data[:, 2], Gridded(Linear()))
# i = interpolate(data[:, 2], BSpline(Linear()))
interpolated = i(range(dmin, dmax, length = N_interpolation_points))

interpolated1 = standardize(ZScoreTransform, interpolated, dims = 1)

p1 = plot(interpolated1, title = "$path")

path = f4
data = CSV.File("$path.csv") |> Tables.matrix

dmax = maximum(data[:, 1])
dmin = minimum(data[:, 1])
nodes = (data[:, 1],)

i = interpolate(nodes, data[:, 2], Gridded(Linear()))
# i = interpolate(data[:, 2], BSpline(Linear()))
interpolated = i(range(dmin, dmax, length = N_interpolation_points))

interpolated2 = standardize(ZScoreTransform, interpolated, dims = 1)

p2 = plot(interpolated2, title = "$path")

plot(p1, p2, layout = (2, 1))
