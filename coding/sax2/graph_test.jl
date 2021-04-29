include("Parameters.jl")
include("ECG.jl")
include("Plotting.jl")
include("SAX.jl")
include("MSAX.jl")

p = Parameters(
    # PAA_segment_count = 360 ÷ 12,
    PAA_segment_count = 18,
    subsequence_length = 6,
    # alphabet_size = 5,
    alphabet_size = 4,
    fs = MIT_BIH_FS,
    # end_index = 7200
)

# e = get_MIT_BIH_ECG(p, 108)
e = get_MIT_BIH_ECG(p, 100)

sym = Symbol.(names(e.data)[2:3])
r = 1:360
time = true

s = sym[1]
p2 = MSAX_ECG_plot(ecg = e, param = p, irange = r, lead = s, time=time)
MSAX_PAA_plot!(p = p2, ecg = e, param = p, irange = r, lead = s, time=time, breakpoints = true)
MSAX_plot!(p = p2, ecg = e, param = p, irange = r, lead = s, time=time, breakpoints = false)

s = sym[2]
p3 = MSAX_ECG_plot(ecg = e, param = p, irange = r, lead = s, time=time)
MSAX_PAA_plot!(p = p3, ecg = e, param = p, irange = r, lead = s, time=time, breakpoints = true)
MSAX_plot!(p = p3, ecg = e, param = p, irange = r, lead = s, time=time, breakpoints = false, upper=true)

p = plot(p2, p3, layout = (2, 1))

savefig(p, "../../writing/slides/pre-defense/graphics/msax.pdf")
return p

# SAX = 16 detected between the two of them

# s = sym[1]
# SAX MLII
# 108, paa=18, sl=12, a=6
# v = 618721:618960 # close
# v = 392881:393120 # right on
# v = 205681:205920 # right on
# v = 295921:296160 # following one
    # v = 457201:457440 # right on
# v = 600721:600960 # following one
# v = 600961:601200 # following one
# v = 164161:164400 # follows one
# v = 180001:180240 # right on 2 of them
# v = 268801:269040 # immediately after 1
# v = 337441:337680 # following one

# s = sym[2]
# SAX V1
# 108, paa=18, sl=12, a=6
# v = 416881:417120 # yes
# v = 450721:450960 # no
# v = 606241:606480 # no
# v = 387841:388080 # noise
# v = 85921:86160   # no
# v = 609841:610080 # no
# v = 604081:604320 # no
# v = 611281:611520 # no
# v = 606001:606240 # no
# v = 625921:626160 # no
# v = 10801:11040   # 4 of them
# v = 86161:86400   # none
# v = 458881:459120 # no
# v = 390241:390480 # no
# v = 468721:468960 # 
# v = 532801:533040 # 
# v = 35281:35520   # 
# v = 54241:54480   # 
# v = 198241:198480 # 
# v = 439441:439680 # maybe noise
# v = 528721:528960 # got 2
# v = 609601:609840 # 
# v = 34081:34320   # 
# v = 86641:86880   # noise
# v = 369601:369840 # giant dip, no annotation
# v = 466321:466560 # 
# v = 469921:470160 # noise
# v = 599041:599280 # yes
# v = 599521:599760 # 
# v = 605281:605520 # 
# v = 620641:620880 # 
# v = 624721:624960 # 

# MSAX: 21 detected in the same area

# MSAX = 21
# 108, paa=18, sl=12, a=6
# v = 416881:417120 # right before
# v = 301441:301680  # yes
# v = 387841:388080  # no, but noise
# v = 10801:11040    # right on 2
# v = 618721:618960  # before 2 of them
# v = 609841:610080  # noise, but no
# v = 598081:598320  # nope, but noise
# v = 469201:469440  # noise, nope
# v = 392881:393120  # 3 of them
# v = 607921:608160  # spike, but no
# v = 604081:604320  # 
# v = 205681:205920  # yes
# v = 604801:605040  # 
# v = 468721:468960  # 
# v = 490801:491040  # 2 of them
# v = 85921:86160    # noise, but no problems
# v = 595681:595920  # yes, noise
# v = 605281:605520  # 
# v = 611041:611280  # 
# v = 167041:167280  # yes
# v = 268561:268800  # yes
# v = 367921:368160  # yes, noise
# v = 450721:450960  # noise
# v = 488881:489120  # 
# v = 606001:606240  # 
# v = 294241:294480  # noise, yes
# v = 372481:372720  # giant spike, but no
# v = 611281:611520  # 
# v = 164161:164400  # 
# v = 461041:461280  # big spike, nothing
# v = 645121:645360  # noise, but no
# v = 451921:452160  # noise, yes
# v = 458881:459120  # 
# v = 625441:625680  # 
# v = 625921:626160  # 
# v = 380401:380640  # noise, yes
# v = 345841:346080  # 
# v = 451201:451440  # 
# v = 107281:107520  # right on
# v = 442561:442800  # 
# v = 86161:86400    # 
# v = 629041:629280  # 
# v = 457201:457440  # yes
# v = 470881:471120  # 
# v = 600721:600960  # 
# v = 502321:502560  # 
# v = 627841:628080  # 
# v = 162721:162960  # noise, yes
# v = 599041:599280  # yes
# v = 606241:606480  # 
# v = 54241:54480    # 
# v = 367441:367680  # noise, yes
# v = 469921:470160  # yes
# v = 35281:35520    # 
# v = 390241:390480  # 
# v = 532801:533040  # 
# v = 596161:596400  # noise, yes
# v = 642961:643200  # 
# v = 466321:466560  # 
# v = 628081:628320  # 
# v = 34081:34320    # 
# v = 428161:428400  # 
# v = 458161:458400  # 
# v = 380161:380400  # 
# v = 301201:301440  # 2 of them
# v = 399841:400080  # yes
# v = 623281:623520  # 
# v = 473041:473280  # 
# v = 581761:582000  # 

# x = 1000 * v[1] ÷ 1000
# r = x-2000:x+2000

# inds = Vector{Int64}()

# for i in r
#     if !ismissing(e.data[i, end-1])
#         println(e.data[i, end-1])
#         if e.data[i, end-1] != "N"
#             println(i)
#             push!(inds, i)
#         end
#     end
# end

# for d in e.data[r, end]
#     if !ismissing(d)
#         println(d)
#     end
# end
# r = 1:360
# r = 1:720
# r = 72001:72720

# p1 = ECG_plot(ecg = e, param = p, irange = r, lead = sym[1], time=time)
# p2 = ECG_plot(ecg = e, param = p, irange = r, lead = sym[2], time=time)
# p3 = MSAX_ECG_plot(ecg = e, param = p, irange = r, lead = sym[1], time=time)
# plot(p1, p2, p3, layout = (3, 1))

# p1 = SAX_ECG_plot(ecg = e, param = p, irange = r, lead = s, time=time)
# SAX_PAA_plot!(p = p1, ecg = e, param = p, irange = r, lead = s, time=time, breakpoints = false)

# plot!(p1, [v[1], v[1]], [-3, 3], label = false, linestyle = :dot)
# plot!(p1, [v[end], v[end]], [-3, 3], label = false, linestyle = :dot)

# if length(inds) != 0
#     for i in inds
#         plot!(p1, [i, i], [-3, 3], label = "anomaly", color = :red)
#     end
# end

# s = sym[1]
# p1 = MSAX_ECG_plot(ecg = e, param = p, irange = r, lead = s, time=time)
# MSAX_PAA_plot!(p = p1, ecg = e, param = p, irange = r, lead = s, time=time, breakpoints = false)

# plot!(p1, [v[1], v[1]], [-3, 3], label = false, linestyle = :dot)
# plot!(p1, [v[end], v[end]], [-3, 3], label = false, linestyle = :dot)

# if length(inds) != 0
#     for i in inds
#         plot!(p1, [i, i], [-3, 3], label = "anomaly", color = :red)
#     end
# end

# s = sym[2]
# p2 = MSAX_ECG_plot(ecg = e, param = p, irange = r, lead = s, time=time)
# MSAX_PAA_plot!(p = p2, ecg = e, param = p, irange = r, lead = s, time=time, breakpoints = false)

# plot!(p2, [v[1], v[1]], [-3, 3], label = false, linestyle = :dot)
# plot!(p2, [v[end], v[end]], [-3, 3], label = false, linestyle = :dot)

# if length(inds) != 0
#     for i in inds
#         plot!(p2, [i, i], [-3, 3], label = "anomaly", color = :red)
#     end
# end

# plot(p1, p2, layout = (2,1), legend=false)
# p0 = ECG_plot(ecg = e, param = p, irange = r, lead = s, time=time)

# p1 = SAX_ECG_plot(ecg = e, param = p, irange = r, lead = s, time=time)
# SAX_PAA_plot!(p = p1, ecg = e, param = p, irange = r, lead = s, time=time, breakpoints = false)
# SAX_plot!(p = p1, ecg = e, param = p, irange = r, lead = s, time=time, breakpoints = true)

# p2 = MSAX_ECG_plot(ecg = e, param = p, irange = r, lead = s, time=time)
# MSAX_PAA_plot!(p = p2, ecg = e, param = p, irange = r, lead = s, time=time, breakpoints = false)
# MSAX_plot!(p = p2, ecg = e, param = p, irange = r, lead = s, time=time, breakpoints = true)

# plot(p0, p1, p2, layout = (3, 1))

# p2 = SAX_ECG_plot(ecg = e, param = p, irange = r, lead = s, time=time)
# SAX_PAA_plot!(p = p2, ecg = e, param = p, irange = r, lead = s, time=time, breakpoints = true)
# return p2

# p3 = MSAX_ECG_plot(ecg = e, param = p, irange = r, lead = s, time=time)
# MSAX_PAA_plot!(p = p3, ecg = e, param = p, irange = r, lead = s, time=time)
# plot(p2, p3, layout = (2, 1))