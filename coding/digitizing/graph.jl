using CSV, Tables, Plots, Interpolations, StatsBase, DataFrames

f1 = "./scans/070bpm-v3"
f2 = "./scans/088bpm-v3"
f3 = "./scans/092bpm-v3"
f4 = "./scans/097bpm-v3"

files = [f1, f2, f3, f4]

N_interpolation_points = Int64(19 * 1//5 * 500)

function interpol(path::String; to_plot::Bool=false)
    data = CSV.File("$path.csv") |> Tables.matrix
    println(size(data))

    dmax = maximum(data[:, 1])
    dmin = minimum(data[:, 1])
    nodes = (data[:, 1],)

    i = interpolate(nodes, data[:, 2], Gridded(Linear()))
# i = interpolate(data[:, 2], BSpline(Linear()))
    interpolated = i(range(dmin, dmax, length = N_interpolation_points))

    interpolated = standardize(ZScoreTransform, interpolated, dims = 1)

    df = DataFrame(sample = collect(1:N_interpolation_points), V3 = interpolated)

#show(df)
#println()

    CSV.write("$path-int-norm.csv", df)

    if to_plot
        p1 = plot(data[:, 2], title = "raw $path")
        p2 = plot(interpolated, title = "interpolated")
        plot(p1, p2, layout = (2, 1))
    end
end

interpol(f1, to_plot = true)


