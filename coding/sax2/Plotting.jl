using Plots

function ECG_plot(; ecg::ECG, param::Parameters, irange::UnitRange{Int64}, lead::Symbol, time::Bool=false)::Plots.Plot{Plots.GRBackend}

    p = plot()

    if time
        p = plot(irange / param.fs, ecg.data[irange, lead], legend = false)
        xlabel!(p, "seconds")
    else
        p = plot(irange, ecg.data[irange, lead], legend = false) 
        xlabel!(p, "samples")
    end
    ylabel!(p, "mV")
    title!(p, "Lead $(strip(String(lead), '_')) of $(ecg.database)/$(ecg.number)")

    return p
end

function SAX_ECG_plot(; ecg::ECG, param::Parameters, irange::UnitRange{Int64}, lead::Symbol, time::Bool=false)::Plots.Plot{Plots.GRBackend}

    normalized_ecg = zeros(Float64, ecg.length, 1)

    SAX_normalize!(src = ecg.data[!, lead], dest = normalized_ecg, col = 1)

    p = plot()

    if time
        p = plot(irange / param.fs, normalized_ecg[irange], legend = false, label = "ECG")
        xlabel!(p, "seconds")
    else
        p = plot(irange, normalized_ecg[irange], legend = false, label = "ECG") 
        xlabel!(p, "samples")
    end
    ylabel!(p, "[no unit]")
    title!(p, "SAX normalized lead $(strip(String(lead), '_')) of $(ecg.database)/$(ecg.number)")

    return p
end

function MSAX_ECG_plot(; ecg::ECG, param::Parameters, irange::UnitRange{Int64}, lead::Symbol, time::Bool=false)::Plots.Plot{Plots.GRBackend}

    normalized_ecg = MSAX_normalize(Matrix{Float64}(ecg.data[:, 2:3]))[:, columnindex(ecg.data, lead)-1]

    p = plot()

    if time
        p = plot(irange / param.fs, normalized_ecg[irange], legend = false, label = "ECG")
        xlabel!(p, "seconds")
    else
        p = plot(irange, normalized_ecg[irange], legend = false, label = "ECG") 
        xlabel!(p, "samples")
    end
    ylabel!(p, "[no unit]")
    title!(p, "MSAX normalized lead $(strip(String(lead), '_')) of $(ecg.database)/$(ecg.number)")

    return p
end

function SAX_PAA_plot!(; p::Plots.Plot{Plots.GRBackend}, ecg::ECG, param::Parameters, lead::Symbol, irange::UnitRange{Int64}, time::Bool=false)

    r = 1:(length(irange)÷param.points_per_segment)

    normalized_ecg = zeros(Float64, ecg.length, 1)
    paa_data = zeros(Float64, ecg.length ÷ param.points_per_segment, 1)

    SAX_normalize!(src = ecg.data[!, lead], dest = normalized_ecg, col = columnindex(ecg.data, lead)-1)

    PAA!(src = normalized_ecg[:, 1], dest = paa_data, col = 1)

    ys = repeat(paa_data[r], inner = 2)
    xs = zeros(Float64, length(ys))

    for (i, y) in enumerate(ys)
        if i % 2 == 1
            xs[i] = (i - 1) * param.points_per_segment / 2 + irange[1]
        else
            xs[i] = i * param.points_per_segment / 2 + + irange[1]
        end
    end

    if time
        xs /= param.fs
    end

    plot!(p, xs, ys, legend=true, label = "PAA") 
    title!(p, "SAX PAA of lead $(strip(String(lead), '_')) of $(ecg.database)/$(ecg.number)")
end

function MSAX_PAA_plot!(; p::Plots.Plot{Plots.GRBackend}, ecg::ECG, param::Parameters, lead::Symbol, irange::UnitRange{Int64}, time::Bool=false)

    r = 1:(length(irange)÷param.points_per_segment)

    paa_data = zeros(Float64, ecg.length ÷ param.points_per_segment, 1)

    normalized_ecg = MSAX_normalize(Matrix{Float64}(ecg.data[:, 2:3]))[:, columnindex(ecg.data, lead)-1]

    PAA!(src = normalized_ecg, dest = paa_data, col = 1)

    ys = repeat(paa_data[r], inner = 2)
    xs = zeros(Float64, length(ys))

    for (i, y) in enumerate(ys)
        if i % 2 == 1
            xs[i] = (i - 1) * param.points_per_segment / 2 + irange[1]
        else
            xs[i] = i * param.points_per_segment / 2 + + irange[1]
        end
    end

    if time
        xs /= param.fs
    end

    plot!(p, xs, ys, legend=true, label = "PAA") 
    title!(p, "MSAX PAA of lead $(strip(String(lead), '_')) of $(ecg.database)/$(ecg.number)")
end