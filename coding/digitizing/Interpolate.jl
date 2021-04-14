using CSV, Tables, Plots, Interpolations, StatsBase, DataFrames

filename1 = "./V3_97bpm"
filename2 = "./V3_70bpm"
path = filename2

N_interpolation_points = 1000

data = CSV.File("$path.csv") |> Tables.matrix

i = interpolate(data[:, 2], BSpline(Linear()))
interpolated = i(range(1, length(i), length = N_interpolation_points))

interpolated = standardize(ZScoreTransform, interpolated, dims = 1)

df = DataFrame(sample = collect(1:N_interpolation_points), V3 = interpolated)
show(df)

CSV.write("$path-int-norm.csv", df)

p1 = plot(data[:, 2])
p2 = plot(interpolated)
plot(p1, p2, layout = (2, 1))

