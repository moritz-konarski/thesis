if !(@isdefined COLOR_BETA)
    const COLOR_ECG = "blue" #palette(:tab10)[1]
    const COLOR_PAA = "orange" #palette(:tab10)[2]
    const COLOR_SAX = "green"
    const COLOR_BETA = "grey"
end

function ECG_plot(; ecg::ECG, param::Parameters, irange::UnitRange{Int64}, lead::Symbol, time::Bool=false, from_zero::Bool=false, to_export::Bool=false)

    title = "Lead $(strip(String(lead), '_')) of $(ecg.database)/$(ecg.number)"
    if to_export
        style = "no marks, line width = 0.7pt, aucablue"
    else
        style = "no marks, line width = 0.7pt, blue"
    end
    axis_style = ""
    # axis_style = "grid=both"
    ylab = "milli Volt"
    xlab = "samples"
    ys = ecg.data[irange, lead]
    xs = collect(irange)

    if time
        xlab = "seconds"
        if from_zero
            xs = collect(1:length(irange)) / param.fs
        else
            xs /= param.fs
        end
    end

    return Axis(PGFPlots.Linear(xs, ys,style = style), style = axis_style, xlabel = xlab, ylabel = ylab, title = title)
end

function SAX_ECG_plot(; ecg::ECG, param::Parameters, irange::UnitRange{Int64}, lead::Symbol, time::Bool=false)

    normalized_ecg = zeros(Float64, ecg.length, 1)

    SAX_normalize!(src = ecg.data[!, lead], dest = normalized_ecg, col = 1)

    p = plot()

    if time
        p = plot(irange / param.fs, normalized_ecg[irange], legend = false, label = "ECG", color = COLOR_ECG)
        xlabel!(p, "seconds")
    else
        p = plot(irange, normalized_ecg[irange], legend = false, label = "ECG", color = COLOR_ECG) 
        xlabel!(p, "samples")
    end
    ylabel!(p, "[no unit]")
    title!(p, "SAX normalized lead $(strip(String(lead), '_')) of $(ecg.database)/$(ecg.number)")

    return p
end

function MSAX_ECG_plot(; ecg::ECG, param::Parameters, irange::UnitRange{Int64}, lead::Symbol, time::Bool=false)

    normalized_ecg = MSAX_normalize(Matrix{Float64}(ecg.data[:, 2:3]))[:, columnindex(ecg.data, lead)-1]

    p = plot()

    if time
        p = plot(irange / param.fs, normalized_ecg[irange], legend = false, label = "ECG", color = COLOR_ECG)
        xlabel!(p, "seconds")
    else
        p = plot(irange, normalized_ecg[irange], legend = false, label = "ECG", color = COLOR_ECG) 
        xlabel!(p, "samples")
    end
    ylabel!(p, "[no unit]")
    title!(p, "MSAX normalized lead $(strip(String(lead), '_')) of $(ecg.database)/$(ecg.number)")

    return p
end

function SAX_PAA_plot!(; p, ecg::ECG, param::Parameters, lead::Symbol, irange::UnitRange{Int64}, time::Bool=false, breakpoints::Bool=false)

    start_index = irange[1] ÷ param.points_per_segment + 1
    end_index = start_index - 1 + length(irange)÷param.points_per_segment

    r = start_index:end_index
    # r = irange[1]÷param.points_per_segment+1:(length(irange)÷param.points_per_segment + irange[1]÷param.points_per_segment)

    normalized_ecg = zeros(Float64, ecg.length, 1)
    paa_data = zeros(Float64, ecg.length ÷ param.points_per_segment, 1)

    SAX_normalize!(src = ecg.data[!, lead], dest = normalized_ecg, col = 1)
    # SAX_normalize!(src = ecg.data[!, lead], dest = normalized_ecg, col = columnindex(ecg.data, lead)-1)

    PAA!(src = normalized_ecg[:, 1], dest = paa_data, col = 1)

    ys = repeat(paa_data[r], inner = 2)
    xs = zeros(Float64, length(ys))

    for (i, y) in enumerate(ys)
        if i % 2 == 1
            xs[i] = (i - 1) * param.points_per_segment / 2 + irange[1]
        else
            xs[i] = i * param.points_per_segment / 2 + irange[1]
        end
    end

    if time
        xs /= param.fs
    end

    plot!(p, xs, ys, legend=true, label = "PAA", color = COLOR_PAA) 
    title!(p, "SAX PAA of lead $(strip(String(lead), '_')) of $(ecg.database)/$(ecg.number)")

    if breakpoints
        β = get_breakpoints(param.alphabet_size)
        if time
            for b in β
                plot!(
                    p,
                    [irange[1], irange[end]]/param.fs,
                    [b, b],
                    linestyle = :dash,
                    label = false,
                    color = COLOR_BETA
                )
            end
        else
            for b in β
                plot!(
                    p,
                    [irange[1], irange[end]],
                    [b, b],
                    linestyle = :dash,
                    label = false,
                    color = COLOR_BETA
                )
            end
        end
    end
end

function MSAX_PAA_plot!(; p, ecg::ECG, param::Parameters, lead::Symbol, irange::UnitRange{Int64}, time::Bool=false, breakpoints::Bool=false)

    start_index = irange[1] ÷ param.points_per_segment + 1
    end_index = start_index - 1 + length(irange)÷param.points_per_segment

    r = start_index:end_index

    # r = 1:(length(irange)÷param.points_per_segment)

    paa_data = zeros(Float64, ecg.length ÷ param.points_per_segment, 1)

    normalized_ecg = MSAX_normalize(Matrix{Float64}(ecg.data[:, 2:3]))[:, columnindex(ecg.data, lead)-1]

    PAA!(src = normalized_ecg, dest = paa_data, col = 1)

    ys = repeat(paa_data[r], inner = 2)
    xs = zeros(Float64, length(ys))

    for (i, y) in enumerate(ys)
        if i % 2 == 1
            xs[i] = (i - 1) * param.points_per_segment / 2 + irange[1]
        else
            xs[i] = i * param.points_per_segment / 2 + irange[1]
        end
    end

    if time
        xs /= param.fs
    end

    plot!(p, xs, ys, legend=true, label = "PAA", color = COLOR_PAA) 
    title!(p, "MSAX PAA of lead $(strip(String(lead), '_')) of $(ecg.database)/$(ecg.number)")

    if breakpoints
        β = get_breakpoints(param.alphabet_size)
        if time
            for b in β
                plot!(
                    p,
                    [irange[1], irange[end]]/param.fs,
                    [b, b],
                    linestyle = :dash,
                    label = false,
                    color = COLOR_BETA
                )
            end
        else
            for b in β
                plot!(
                    p,
                    [irange[1], irange[end]],
                    [b, b],
                    linestyle = :dash,
                    label = false,
                    color = COLOR_BETA
                )
            end
        end
    end
end

function SAX_plot!(; p, ecg::ECG, param::Parameters, lead::Symbol, irange::UnitRange{Int64}, time::Bool=false, breakpoints::Bool=false)

    start_index = irange[1] ÷ param.points_per_segment + 1
    end_index = start_index - 1 + length(irange)÷param.points_per_segment

    r = start_index:end_index
    # r = 1:(length(irange)÷param.points_per_segment)
    index = columnindex(ecg.data, lead)-1 

    normalized_ecg = zeros(Float64, ecg.length, 1)
    paa_data = zeros(Float64, ecg.length ÷ param.points_per_segment, 1)

    SAX_normalize!(src = ecg.data[!, lead], dest = normalized_ecg, col = 1)

    PAA!(src = normalized_ecg[:, 1], dest = paa_data, col = 1)

    sax = SAX(ecg = ecg, param = param)

    ys = paa_data[r]
    xs = zeros(Float64, length(ys))

    for (i, y) in enumerate(ys)
        xs[i] = 2 * (i - 0.5) * param.points_per_segment / 2 + irange[1]
    end

    if time
        xs /= param.fs
    end

    plot!(
        p,
        xs,
        ys,
        seriestype = :scatter,
        series_annotations = text.(al.(sax.data[r, index]), :bottom),
        label = "SAX",
        markercolor = COLOR_SAX,
        markersize = 3
    )

    title!(p, "SAX of lead $(strip(String(lead), '_')) of $(ecg.database)/$(ecg.number)")

    if breakpoints
        β = get_breakpoints(param.alphabet_size)
        if time
            for b in β
                plot!(
                    p,
                    [irange[1], irange[end]]/param.fs,
                    [b, b],
                    linestyle = :dash,
                    label = false,
                    color = COLOR_BETA
                )
            end
        else
            for b in β
                plot!(
                    p,
                    [irange[1], irange[end]],
                    [b, b],
                    linestyle = :dash,
                    label = false,
                    color = COLOR_BETA
                )
            end
        end
    end
end

function MSAX_plot!(; p, ecg::ECG, param::Parameters, lead::Symbol, irange::UnitRange{Int64}, time::Bool=false, breakpoints::Bool=false, upper::Bool=false)

    start_index = irange[1] ÷ param.points_per_segment + 1
    end_index = start_index - 1 + length(irange)÷param.points_per_segment

    r = start_index:end_index

    index = columnindex(ecg.data, lead)-1 
    # r = 1:(length(irange)÷param.points_per_segment)

    paa_data = zeros(Float64, ecg.length ÷ param.points_per_segment, 1)

    normalized_ecg = MSAX_normalize(Matrix{Float64}(ecg.data[:, 2:3]))[:, columnindex(ecg.data, lead)-1]

    PAA!(src = normalized_ecg, dest = paa_data, col = 1)

    msax = MSAX(ecg = ecg, param = param)

    data = [ t[index] for t in msax.data[r]]

    ys = paa_data[r]
    xs = zeros(Float64, length(ys))

    for (i, y) in enumerate(ys)
        xs[i] = 2 * (i - 0.5) * param.points_per_segment / 2 + irange[1]
    end

    if time
        xs /= param.fs
    end

    if upper
        plot!(
            p,
            xs,
            ys,
            seriestype = :scatter,
            series_annotations = text.(uppercase.(al.(data)), :bottom),
            label = "MSAX",
            markercolor = COLOR_SAX,
            markersize = 3
        )
    else
        plot!(
            p,
            xs,
            ys,
            seriestype = :scatter,
            series_annotations = text.(al.(data), :bottom),
            label = "MSAX",
            markercolor = COLOR_SAX,
            markersize = 3
        )
    end

    title!(p, "MSAX of lead $(strip(String(lead), '_')) of $(ecg.database)/$(ecg.number)")

    if breakpoints
        β = get_breakpoints(param.alphabet_size)
        if time
            for b in β
                plot!(
                    p,
                    [irange[1], irange[end]]/param.fs,
                    [b, b],
                    linestyle = :dash,
                    label = false,
                    color = COLOR_BETA
                )
            end
        else
            for b in β
                plot!(
                    p,
                    [irange[1], irange[end]],
                    [b, b],
                    linestyle = :dash,
                    label = false,
                    color = COLOR_BETA
                )
            end
        end
    end
end

function al(x)
    return 'a' + (x - 1)
end