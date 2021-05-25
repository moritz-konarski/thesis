file_name <- "./outlier_data/no_sub-dual_sax.csv"
save_name <- "./outlier_data/no_sub-dual_sax-summary_msax.csv"
use_msax <- T

data <- read.csv2(file_name)

a <- c(NA)
p <- c(NA)
k <- c(NA)
s <- c(NA)
rec <- c(NA)
acc <- c(NA)
prec <- c(NA)
f1 <- c(NA)

if (use_msax) {
    data <- data[data$is_msax == 1,]
    len <- dim(data)[1] / 48
} else {
    data <- data[data$is_msax == 0,]
    len <- dim(data)[1] / 48 / 2
}

length(a) <- len
length(p) <- len
length(k) <- len
length(s) <- len
length(rec) <- len
length(acc) <- len
length(prec) <- len
length(f1) <- len

count <- 0

all_k <- unique(data$k)

for (curr_k in all_k) {
    s1 <- data[data$k == curr_k,]
    all_paa <- unique(s1$paa_segment_count)
    for (curr_paa in all_paa) {
        s2 <- s1[s1$paa_segment_count == curr_paa,]
        all_sub <- unique(s2$subsequence_length)
        for (curr_sub in all_sub) {
            s3 <- s2[s2$subsequence_length == curr_sub,]
            all_alph <- unique(s3$alphabet_size)
            for (curr_alph in all_alph) {
                count <- count + 1
                print(paste0(count, " / ", len, "  ", round(100 * count / len, 1)))
                a[count] <- curr_alph
                p[count] <- curr_paa
                k[count] <- curr_k
                s[count] <- curr_sub
                rec[count] <- mean(s3[s3$alphabet_size == curr_alph,]$recall, na.rm=T)
                acc[count] <- mean(s3[s3$alphabet_size == curr_alph,]$accuracy, na.rm=T)
                prec[count] <- mean(s3[s3$alphabet_size == curr_alph,]$precision, na.rm=T)
                f1[count] <- mean(s3[s3$alphabet_size == curr_alph,]$f1, na.rm=T)
            }
        }
    }
}

data_summ <-
    data.frame(
        k = k,
        paa_count = p,
        subsequence = s,
        alphabet_size = a,
        recall = rec,
        accuracy = acc,
        precision = prec,
        f1 = f1
    )

write.csv2(data_summ, save_name, row.names = F)
