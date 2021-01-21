# time: 2021-01-20 16:46:12 +06
# mode: pkg
	update
# time: 2021-01-20 16:47:07 +06
# mode: pkg
	add FFTW
# time: 2021-01-20 16:48:23 +06
# mode: pkg
	add AbstractFFTs
# time: 2021-01-20 16:48:57 +06
# mode: julia
	using FFTW
# time: 2021-01-20 16:49:17 +06
# mode: julia
	fft([0; 1; 2; 1;])
# time: 2021-01-20 16:50:06 +06
# mode: pkg
	add FastTransforms
# time: 2021-01-20 16:56:11 +06
# mode: pkg
	add DSP
# time: 2021-01-20 16:56:15 +06
# mode: pkg
	add Wavelets
# time: 2021-01-20 16:56:39 +06
# mode: pkg
	add FastTransforms
# time: 2021-01-20 16:56:46 +06
# mode: pkg
	add FFTW
# time: 2021-01-20 16:56:49 +06
# mode: julia
	la
# time: 2021-01-20 16:56:53 +06
# mode: julia
	dir
# time: 2021-01-20 16:56:55 +06
# mode: julia
	dir()
# time: 2021-01-20 16:57:00 +06
# mode: julia
	getcd()
# time: 2021-01-20 16:58:47 +06
# mode: julia
	exit()
# time: 2021-01-20 18:55:53 +06
# mode: julia
	using FFTW
# time: 2021-01-20 18:56:26 +06
# mode: julia
	using CSV
# time: 2021-01-20 18:56:32 +06
# mode: pkg
	add CSV
# time: 2021-01-20 18:59:27 +06
# mode: julia
	using CSV
# time: 2021-01-20 19:00:42 +06
# mode: julia
	df = CSV.File("100.csv"; header-false)
# time: 2021-01-20 19:00:47 +06
# mode: julia
	df = CSV.File("100.csv"; header=false)
# time: 2021-01-20 19:02:25 +06
# mode: julia
	df = CSV.File("100.csv"; header=false) |> Tables.matrix
# time: 2021-01-20 19:02:53 +06
# mode: julia
	using DelimitedFiles
# time: 2021-01-20 19:02:57 +06
# mode: julia
	df = CSV.File("100.csv"; header=false) |> Tables.matrix
# time: 2021-01-20 19:03:01 +06
# mode: julia
	using Tables
# time: 2021-01-20 19:03:09 +06
# mode: pkg
	add Tables
# time: 2021-01-20 19:03:37 +06
# mode: julia
	using Tables
# time: 2021-01-20 19:03:41 +06
# mode: julia
	df = CSV.File("100.csv"; header=false) |> Tables.matrix
# time: 2021-01-20 19:03:52 +06
# mode: julia
	df
# time: 2021-01-20 19:03:55 +06
# mode: julia
	df[1]
# time: 2021-01-20 19:04:09 +06
# mode: julia
	df[1][1]
# time: 2021-01-20 19:04:13 +06
# mode: julia
	df[1,1]
# time: 2021-01-20 19:04:24 +06
# mode: julia
	df[1,0]
# time: 2021-01-20 19:04:33 +06
# mode: julia
	df[1,4]
# time: 2021-01-20 19:04:36 +06
# mode: julia
	df[1,3]
# time: 2021-01-20 19:04:55 +06
# mode: julia
	df[1,]
# time: 2021-01-20 19:05:07 +06
# mode: julia
	df[1,1:650000]
# time: 2021-01-20 19:05:22 +06
# mode: julia
	df[1,1:649999]
# time: 2021-01-20 19:06:03 +06
# mode: julia
	df[1,:]
# time: 2021-01-20 19:06:18 +06
# mode: julia
	df[:,1]
# time: 2021-01-20 19:06:27 +06
# mode: julia
	fft(df[:,1])
# time: 2021-01-20 19:07:26 +06
# mode: julia
	using Plots
# time: 2021-01-20 19:07:31 +06
# mode: pkg
	add Plots
# time: 2021-01-20 19:47:46 +06
# mode: julia
	using Plots
# time: 2021-01-20 19:52:40 +06
# mode: julia
	exit()
# time: 2021-01-20 19:52:47 +06
# mode: julia
	using Plots
# time: 2021-01-20 19:53:44 +06
# mode: pkg
	add GR
# time: 2021-01-20 19:55:18 +06
# mode: julia
	using Plots
# time: 2021-01-20 19:56:26 +06
# mode: pkg
	Pkg.build("GR")
# time: 2021-01-20 19:56:33 +06
# mode: pkg
	usng Pkg
# time: 2021-01-20 19:56:37 +06
# mode: pkg
	using Pkg
# time: 2021-01-20 19:56:44 +06
# mode: julia
	using Pkg
# time: 2021-01-20 19:56:49 +06
# mode: julia
	Pkg.build("GR")
# time: 2021-01-20 19:57:57 +06
# mode: julia
	using Plots
# time: 2021-01-20 19:59:05 +06
# mode: julia
	using FFTW
# time: 2021-01-20 19:59:20 +06
# mode: julia
	using CSV
# time: 2021-01-20 19:59:33 +06
# mode: julia
	df = CSV.File("100.csv"; header=false) |> Tables.matrix
# time: 2021-01-20 20:00:00 +06
# mode: julia
	using Tables
# time: 2021-01-20 20:00:06 +06
# mode: julia
	df = CSV.File("100.csv"; header=false) |> Tables.matrix
# time: 2021-01-20 20:00:32 +06
# mode: julia
	F = fft(df[1:720,:])
# time: 2021-01-20 20:00:40 +06
# mode: julia
	F = fft(df[1:720,1])
# time: 2021-01-20 20:01:57 +06
# mode: julia
	time_domain = plot(0:(1/360):2, df[1:720,1], title = "Signal")
# time: 2021-01-20 20:03:31 +06
# mode: julia
	time_domain = plot((1/360):(1/360):2, df[1:720,1], title = "Signal")
# time: 2021-01-20 20:03:54 +06
# mode: julia
	time_domain = plot((1/360):(1/360):20, df[1:7200,1], title = "Signal")
# time: 2021-01-20 20:04:21 +06
# mode: julia
	df[1:720,1]
# time: 2021-01-20 20:04:31 +06
# mode: julia
	df[1:7200,1]
# time: 2021-01-20 20:04:38 +06
# mode: julia
	df[1:7200,2]
# time: 2021-01-20 20:04:42 +06
# mode: julia
	df[1:7200,3]
# time: 2021-01-20 20:05:02 +06
# mode: julia
	time_domain = plot(df[1:720,1], df[1:720,2], title = "Signal")
# time: 2021-01-20 20:05:24 +06
# mode: julia
	time_domain = plot(df[1:720,1], df[1:720,2], title = "Heartbeat")
# time: 2021-01-20 20:05:45 +06
# mode: julia
	time_domain = plot(df[1:720,1], df[1:720,3], title = "Heartbeat")
# time: 2021-01-20 20:06:02 +06
# mode: julia
	time_domain = plot(df[1:720,1], df[1:720,2, df[1:720,3], title = "Heartbeat")
# time: 2021-01-20 20:06:07 +06
# mode: julia
	time_domain = plot(df[1:720,1], df[1:720,2], df[1:720,3], title = "Heartbeat")
# time: 2021-01-20 20:06:40 +06
# mode: julia
	time_domain = plot(df[1:720,1], df[1:720,2], title = "Heartbeat")
# time: 2021-01-20 20:07:25 +06
# mode: julia
	time_domain = plot(-100:100, fft(df[1:720,2]), title = "FFT")
# time: 2021-01-20 20:07:55 +06
# mode: julia
	time_domain = plot(-100:(1/720):100, fft(df[1:720,2]), title = "FFT")
# time: 2021-01-20 20:08:10 +06
# mode: julia
	time_domain = plot(-100:(1/7.2):100, fft(df[1:720,2]), title = "FFT")
# time: 2021-01-20 20:08:32 +06
# mode: julia
	time_domain = plot(-360:360, fft(df[1:720,2]), title = "FFT")
# time: 2021-01-20 20:08:37 +06
# mode: julia
	time_domain = plot(-3590:360, fft(df[1:720,2]), title = "FFT")
# time: 2021-01-20 20:08:42 +06
# mode: julia
	time_domain = plot(-359:360, fft(df[1:720,2]), title = "FFT")
# time: 2021-01-20 20:08:54 +06
# mode: julia
	time_domain = plot(-359:360, fft(df[1:720,2])[1], title = "FFT")
# time: 2021-01-20 20:09:31 +06
# mode: julia
	time_domain = plot(-359:360, real(fft(df[1:720,2])), title = "FFT")
# time: 2021-01-20 20:09:58 +06
# mode: julia
	time_domain = plot(-718:2:720, real(fft(df[1:720,2])), title = "FFT")
# time: 2021-01-20 20:10:21 +06
# mode: julia
	time_domain = plot(real(fft(df[1:720,2])), title = "FFT")
# time: 2021-01-20 20:11:24 +06
# mode: julia
	time_domain = plot(1:0.5:360, real(fft(df[1:720,2])), title = "FFT")
# time: 2021-01-20 20:11:31 +06
# mode: julia
	time_domain = plot(0.5:0.5:360, real(fft(df[1:720,2])), title = "FFT")
# time: 2021-01-20 20:11:51 +06
# mode: julia
	real(fft(df[1:720,2]))
# time: 2021-01-20 20:12:18 +06
# mode: julia
	exit()
