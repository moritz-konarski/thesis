
d <- "./outlier_data/"
beat <- F
data1 <- read.csv2(paste0(
    d,
    "data-beat_types-", beat, "--single-TRUE--first_sax-FALSE.csv"
))[, -1]
data2 <- read.csv2(paste0(
    d,
    "data-beat_types-", beat, "--single-TRUE--first_sax-TRUE.csv"
))[, -1]

s2 <- data2[data2$is_msax == 0,]
data1 <- rbind(data1, s2)

write.csv2(data1,
           paste0("./outlier_data/no_sub-single_sax.csv"),
           row.names = F)

data <- read.csv2("./real_test_2/data-beat_types-FALSE--single-FALSE--first_sax-FALSE.csv")
write.csv2(data[,-1], "./data/sub-dual_sax.csv", row.names = F)

