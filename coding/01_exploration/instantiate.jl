using Pkg
Pkg.update()
Pkg.add("PackageCompiler")

using PackageCompiler, IJulia, Plots, FFTW, DSP, CSV, Tables

create_sysimage([:Plots, :FFTW, :DSP, :CSV, :Tables], sysimage_path="/home/moritz/Documents/thesis.git/coding/01_exploration/01_explore.so")

IJulia.installkernel("Julia Thesis 01", "--sysimage=/home/moritz/Documents/thesis.git/coding/01_exploration/01_explore.so")
