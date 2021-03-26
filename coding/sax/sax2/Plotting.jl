"""
SUMMARY
Collection of functions to plot ECGs

META-INFO
Date: 25.03.2021
Author: Moritz M. Konarski
Email: konarski_m@auca.kg
GitHub: @moritz-konarski (https://github.com/moritz-konarski)
"""

using Plots

function ecg_plot(;
    ecg::ECG,
    param::Parameters,
    plot_seconds::Bool = false,
    title::Bool = true,
    label::String = "",
)

    @info "Plotting ECG $(ecg.type.name)/$(ecg.number)"

    ys = reshape(ecg.data, :, 1)[:]
    p = missing

    if plot_seconds
        xs = [param.start_index:param.end_index] / ecg.type.fs
        p = plot(xs, ys, label = label)
        xlabel!("Seconds")
    else
        xs = [param.start_index:param.end_index]
        p = plot(xs, ys, label = label)
        xlabel!("Data Points")
    end

    if ecg.is_normalized[1]
        ylabel!(p, "[No unit]")
        if title
            title!(p, "$(ecg.type.name)/$(ecg.number) z-normalized")
        end
    else
        ylabel!(p, "milli Volt")
        if title
            title!(p, "$(ecg.type.name)/$(ecg.number)")
        end
    end

    return p
end

function paa_plot(;
    paa::PAA,
    ecg::ECG,
    param::Parameters,
    plot_seconds::Bool = false,
    title::Bool = true,
    label::String = "",
)

    @info "Plotting PAA of $(ecg.type.name)/$(ecg.number)"

    p = missing
    ys = repeat(reshape(paa.data, :, 1)[:], inner = 2)

    # @info paa.data

    segment_length = size(ecg.data)[1] ÷ param.subsequence_length

    xs = zeros(Float64, length(ys))
    for (i, y) in enumerate(ys)
        if i % 2 == 1
            xs[i] = (i - 1) * segment_length / 2 + param.start_index
        else
            xs[i] = i * segment_length / 2 + param.start_index
        end
    end

    if plot_seconds[1]
        xs /= param.type.fs
        p = plot(xs, ys, label = label)
        xlabel!("Seconds")
    else
        p = plot(xs, ys, label = label)
        xlabel!("Data Points")
    end

    ylabel!(p, "[No unit]")
    if title
        title!(p, "PAA of $(ecg.type.name)/$(ecg.number)")
    end

    return p
end

function paa_ecg_plot(;
    paa::PAA,
    ecg::ECG,
    param::Parameters,
    plot_seconds::Bool = false,
    title::Bool = true,
    label::String = "",
)

    @info "Plotting PAA and ECG $(ecg.type.name)/$(ecg.number)"

    @info "1: Plotting ECG $(ecg.type.name)/$(ecg.number)"

    ys = reshape(ecg.data, :, 1)[:]
    p = missing

    if plot_seconds
        xs = [param.start_index:param.end_index] / ecg.type.fs
        p = plot(xs, ys, label = label)
        xlabel!("Seconds")
    else
        xs = [param.start_index:param.end_index]
        p = plot(xs, ys, label = label)
        xlabel!("Data Points")
    end

    if ecg.is_normalized[1]
        ylabel!(p, "[No unit]")
        if title
            title!(p, "$(ecg.type.name)/$(ecg.number) z-normalized")
        end
    else
        ylabel!(p, "milli Volt")
        if title
            title!(p, "$(ecg.type.name)/$(ecg.number)")
        end
    end

    @info "2: Plotting PAA of $(ecg.type.name)/$(ecg.number)"

    ys = repeat(reshape(paa.data, :, 1)[:], inner = 2)

    segment_length = size(ecg.data)[1] ÷ param.subsequence_length

    xs = zeros(Float64, length(ys))
    for (i, y) in enumerate(ys)
        if i % 2 == 1
            xs[i] = (i - 1) * segment_length / 2 + param.start_index
        else
            xs[i] = i * segment_length / 2 + param.start_index
        end
    end

    if plot_seconds
        xs /= param.type.fs
        plot!(xs, ys, label = label)
    else
        plot!(xs, ys, label = label)
    end

    return p
end

function paa_sax_plot(;
    paa::PAA,
    ecg::ECG,
    sax::SAX,
    param::Parameters,
    plot_seconds::Bool = false,
    title::Bool = true,
    label::String = "",
)

    @info "Plotting SAX and PAA $(ecg.type.name)/$(ecg.number)"

    @info "1: Plotting PAA of $(ecg.type.name)/$(ecg.number)"

    p = missing
    ys = repeat(reshape(paa.data, :, 1)[:], inner = 2)

    segment_length = size(ecg.data)[1] ÷ param.subsequence_length

    xs = zeros(Float64, length(ys))
    for (i, y) in enumerate(ys)
        if i % 2 == 1
            xs[i] = (i - 1) * segment_length / 2 + param.start_index
        else
            xs[i] = i * segment_length / 2 + param.start_index
        end
    end

    if plot_seconds
        xs /= param.type.fs
        p = plot(xs, ys, label = label)
        xlabel!("Seconds")
    else
        p = plot(xs, ys, label = label)
        xlabel!("Data Points")
    end

    ylabel!(p, "[No unit]")
    if title
        title!(p, "PAA of $(ecg.type.name)/$(ecg.number)")
    end

    @info "2: Plotting SAX of $(ecg.type.name)/$(ecg.number)"

    ys = reshape(paa.data, :, 1)[:]

    xs = zeros(Float64, length(ys))
    for (i, y) in enumerate(ys)
        xs[i] = 2 * (i - 0.5) * segment_length / 2 + param.start_index
    end

    plot!(
        xs,
        ys,
        seriestype = :scatter,
        series_annotations = text.(reshape(sax.data, :, 1)[:], :bottom),
        label = label,
    )

    return p
end

function ecg_paa_sax_plot(;
    paa::PAA,
    sax::SAX,
    ecg::ECG,
    param::Parameters,
    plot_seconds::Bool = false,
    title::Bool = true,
    label::String = "",
)

    @info "Plotting SAX, PAA and ECG $(ecg.type.name)/$(ecg.number)"

    @info "1: Plotting ECG $(ecg.type.name)/$(ecg.number)"

    ys = reshape(ecg.data, :, 1)[:]
    p = missing

    if plot_seconds
        xs = [param.start_index:param.end_index] / ecg.type.fs
        p = plot(xs, ys, label = label)
        xlabel!("Seconds")
    else
        xs = [param.start_index:param.end_index]
        p = plot(xs, ys, label = label)
        xlabel!("Data Points")
    end

    if ecg.is_normalized[1]
        ylabel!(p, "[No unit]")
        if title
            title!(p, "$(ecg.type.name)/$(ecg.number) z-normalized")
        end
    else
        ylabel!(p, "milli Volt")
        if title
            title!(p, "$(ecg.type.name)/$(ecg.number)")
        end
    end

    @info "2: Plotting PAA of $(ecg.type.name)/$(ecg.number)"

    ys = repeat(reshape(paa.data, :, 1)[:], inner = 2)

    segment_length = size(ecg.data)[1] ÷ param.subsequence_length

    xs = zeros(Float64, length(ys))
    for (i, y) in enumerate(ys)
        if i % 2 == 1
            xs[i] = (i - 1) * segment_length / 2 + param.start_index
        else
            xs[i] = i * segment_length / 2 + param.start_index
        end
    end

    if plot_seconds
        xs /= param.type.fs
        plot!(xs, ys, label = label)
    else
        plot!(xs, ys, label = label)
    end

    @info "3: Plotting SAX of $(ecg.type.name)/$(ecg.number)"

    ys = reshape(paa.data, :, 1)[:]

    xs = zeros(Float64, length(ys))
    for (i, y) in enumerate(ys)
        xs[i] = 2 * (i - 0.5) * segment_length / 2 + param.start_index
    end

    plot!(
        xs,
        ys,
        seriestype = :scatter,
        series_annotations = text.(reshape(sax.data, :, 1)[:], :bottom),
        label = label,
    )

    return p
end
