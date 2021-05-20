
d <- "./real_test_2/"
beat <- F
data1 <- read.csv2(paste0(
    d,
    "data-beat_types-", beat, "--single-TRUE--first_sax-FALSE.csv"
))
data2 <- read.csv2(paste0(
    d,
    "data-beat_types-", beat, "--single-TRUE--first_sax-TRUE.csv"
))

s2 <- data2[data2$is_msax == 0,]
data1 <- rbind(data1, s2)

write.csv2(data1,
           paste0(d, "data-beat_types-", beat, "--single-combined.csv"))
