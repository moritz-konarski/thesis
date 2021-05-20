d <- "./real_test_1/"
# d <- "./real_test_2/"
beat <- T
# beat <- F
use_msax <- F
# use_msax <- F
# file_name <-
#     paste0(d, "data-beat_types-", beat, "--single-combined.csv")
file_name <-
    paste0(d, "data-beat_types-", beat, "--single-FALSE--first_sax-FALSE.csv")

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

sorted_data_summ <- data_summ[order(data_summ$recall, decreasing=T), ]


# a bunch of these 
t <- sorted_data_summ[sorted_data_summ$alphabet_size <= 8 & sorted_data_summ$paa_count < 30, ]

s <- sorted_data_summ[sorted_data_summ$k > 0, ]

# top25 <- sorted_data_summ[1:25, ]

# msax:
#     sorted
#      k paa_count subsequence alphabet_size    recall accuracy precision        f1
# 136 -1       180         180            24 1.0000000 0.494229 0.4941943 0.5586295
# 137 -1       180         180            25 1.0000000 0.494229 0.4941943 0.5586295
# 304 -1       360         360            24 1.0000000 0.494229 0.4941943 0.5586295
# 305 -1       360         360            25 1.0000000 0.494229 0.4941943 0.5586295
# 65  -1       120         120            25 0.9999873 0.494229 0.4942037 0.5586289
# 134 -1       180         180            22 0.9999873 0.494229 0.4942037 0.5586289

c1 <- data$is_msax == 1 & data$k == -1 & data$paa_segment_count == 180 & data$subsequence_length == 180 & data$alphabet_size == 24
c2 <- data$is_msax == 1 & data$k == -1 & data$paa_segment_count == 180 & data$subsequence_length == 180 & data$alphabet_size == 25
c3 <- data$is_msax == 1 & data$k == -1 & data$paa_segment_count == 360 & data$subsequence_length == 360 & data$alphabet_size == 24
c4 <- data$is_msax == 1 & data$k == -1 & data$paa_segment_count == 360 & data$subsequence_length == 360 & data$alphabet_size == 25
c5 <- data$is_msax == 1 & data$k == -1 & data$paa_segment_count == 120 & data$subsequence_length == 120 & data$alphabet_size == 25

plot_data <- data[c1 | c2 | c3 | c4 | c5, ]
p1 <- data[c1, ]
p2 <- data[c2, ]
p3 <- data[c3, ]
p4 <- data[c4, ]
p5 <- data[c5, ]

library(ggplot2)

ggplot(plot_data, aes(x = as.factor(c(1, 2, 3, 4, 5)), y = recall)) +
    geom_boxplot(p1, aes(x = recall, y = as.factor(c(1))))

ggplot(p1, aes(x = as.factor(is_msax), y = recall)) +
    geom_boxplot()

#     t
#      k paa_count subsequence alphabet_size    recall  accuracy precision        f1
# 215 -1        24          24             8 0.7845831 0.5579063 0.5171090 0.5041155
# 191 -1        20          20             8 0.7204068 0.5681671 0.5221129 0.4861185
# 119 -1        18          18             8 0.6886046 0.5742151 0.5275415 0.4745284
# 214 -1        24          24             7 0.6752171 0.5710757 0.5268397 0.4692678
# 95  -1        15          15             8 0.6187431 0.5840143 0.5393886 0.4511169
# 190 -1        20          20             7 0.6126713 0.5794437 0.5369299 0.4477713

# single sax:
#     sorted
#      k paa_count subsequence alphabet_size    recall  accuracy precision        f1
# 305 -1       360         360            25 0.9968317 0.4953255 0.4943792 0.5582366
# 304 -1       360         360            24 0.9963791 0.4955332 0.4944685 0.5581842
# 303 -1       360         360            23 0.9961438 0.4954582 0.4945201 0.5581383
# 137 -1       180         180            25 0.9954380 0.4953197 0.4946063 0.5579860
# 302 -1       360         360            22 0.9954242 0.4955217 0.4946112 0.5580300
# 301 -1       360         360            21 0.9949154 0.4956198 0.4947034 0.5579146
#     t
#      k paa_count subsequence alphabet_size    recall  accuracy precision        f1
# 305 -1       360         360            25 0.9968317 0.4953255 0.4943792 0.5582366
# 304 -1       360         360            24 0.9963791 0.4955332 0.4944685 0.5581842
# 303 -1       360         360            23 0.9961438 0.4954582 0.4945201 0.5581383
# 137 -1       180         180            25 0.9954380 0.4953197 0.4946063 0.5579860
# 302 -1       360         360            22 0.9954242 0.4955217 0.4946112 0.5580300
# 301 -1       360         360            21 0.9949154 0.4956198 0.4947034 0.5579146

# dual sax:
#     sorted
#      k paa_count subsequence alphabet_size    recall  accuracy precision        f1
# 305 -1       360         360            25 0.9999618 0.4941828 0.4941579 0.5585880
# 301 -1       360         360            21 0.9997838 0.4941828 0.4941474 0.5585681
# 302 -1       360         360            22 0.9997838 0.4941944 0.4941579 0.5585739
# 303 -1       360         360            23 0.9997838 0.4941944 0.4941579 0.5585739
# 304 -1       360         360            24 0.9997838 0.4941944 0.4941579 0.5585739
# 64  -1       120         120            24 0.9997722 0.4941944 0.4941582 0.5585687
#     t
#        k paa_count subsequence alphabet_size    recall  accuracy precision        f1
# 215   -1        24          24             8 0.5484662 0.5986958 0.5528009 0.4296266
# 191   -1        20          20             8 0.4706129 0.5999077 0.5672767 0.4008766
# 214   -1        24          24             7 0.4539271 0.5932248 0.5740069 0.3820904
# 119   -1        18          18             8 0.4293355 0.5965143 0.5788390 0.3790927
# 3527 300        24          24             8 0.3971381 0.5536242 0.5852870 0.3317631
# 190   -1        20          20             7 0.3798480 0.5899931 0.5955946 0.3521321
# 

