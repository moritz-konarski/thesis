# real test 1 is the important one
# subsequences

library(tikzDevice)
plot_width <- 8
plot_height <- 5
get_ecgs <- function(ecg, v) {
    return(ecg[ecg$k == v[,1] & 
                   ecg$paa_segment_count == v[,2] & 
                   ecg$subsequence_length == v[,3] & 
                   ecg$alphabet_size == v[,4], ])
}

len <- 25
threshold <- 0.95
msax_data <- read.csv2("./data/sub-dual_sax-summary_msax.csv")
msax_data <- msax_data[msax_data$recall >= threshold, ]
msax_data <- msax_data[order(msax_data$precision, decreasing = T), ]
dsax_data <- read.csv2("./data/sub-dual_sax-summary_sax.csv")
dsax_data <- dsax_data[dsax_data$recall >= threshold, ]
dsax_data <- dsax_data[order(dsax_data$precision, decreasing = T), ]
ssax_data <- read.csv2("./data/sub-single_sax-summary_sax.csv")
ssax_data <- ssax_data[ssax_data$recall >= threshold, ]
ssax_data <- ssax_data[order(ssax_data$precision, decreasing = T), ]

# for these there are only 3 for sax, 13 for dual sax, and 23 for msax
# out of all 4968 the files only those -> bad
# this is why new data was needed.
# if all segments for where paa = m are removed, ssax has 0, dsax has 0, msax has    3

# no subsequences

len <- 25
threshold <- 0.95
msax_data <- read.csv2("./data/no_sub-dual_sax-summary_msax.csv")
msax_data <- msax_data[msax_data$recall >= threshold, ]
msax_data <- msax_data[order(msax_data$precision, decreasing = T), ]
dsax_data <- read.csv2("./data/no_sub-dual_sax-summary_sax.csv")
dsax_data <- dsax_data[dsax_data$recall >= threshold, ]
dsax_data <- dsax_data[order(dsax_data$precision, decreasing = T), ]
ssax_data <- read.csv2("./data/no_sub-single_sax-summary_sax.csv")
ssax_data <- ssax_data[ssax_data$recall >= threshold, ]
ssax_data <- ssax_data[order(ssax_data$precision, decreasing = T), ]

# for these there are 99 for sax, 192 for dual sax, and 255 for msax

actual_data <- read.csv2("./real_test_1/data-beat_types-FALSE--single-FALSE--first_sax-FALSE.csv")
actual_msax <- actual_data[actual_data$is_msax == 1, ]
actual_dsax <- actual_data[actual_data$is_msax == 0, ]
actual_data <- read.csv2("./real_test_1/data-beat_types-FALSE--single-TRUE--first_sax-FALSE.csv")
actual_ssax <- actual_data[actual_data$is_msax == 0, ]
actual_data <- read.csv2("./real_test_1/data-beat_types-FALSE--single-TRUE--first_sax-TRUE.csv")
actual_ssax <- rbind(actual_ssax, actual_data[actual_data$is_msax == 0, ])
actual_data <- NA

actual_data <- actual_msax
ran <- 1:10
summary <- msax_data[ran, 1:4]
d <- data.frame()
for (i in ran) {
    d <- rbind(d, cbind(get_ecgs(actual_data, summary[i, ]), data.frame(rank = rep(i, 48))))
}
boxplot(recall ~ rank, data = d)
boxplot(precision ~ rank, data = d)


# SSAX BOXPLOT
actual_data <- actual_ssax
ran <- 1:10
summary <- ssax_data[ran, 1:4]
d <- data.frame()
iqrs <- c(NA)
length(iqrs) <- 10
ranks <- c(NA)
length(ranks) <- 10
num_ol <- c(NA)
length(num_ol) <- 10
for (i in ran) {
    ecgs <- get_ecgs(actual_data, summary[i, ])
    d <- rbind(d, cbind(ecgs, data.frame(rank = rep(i, 48))))
    iqrs[i] <- IQR(ecgs$recall)
    ranks[i] <- i
    num_ol[i] <- sum(ecgs$recall < quantile(ecgs$recall)[2] - 1.5 * iqrs[i])
}
iqr_rank <- data.frame(rank = ranks, iqr_val = iqrs, outliers = num_ol)
iqr_rank <- iqr_rank[order(iqr_rank$iqr_val), ]

tikz(file = "../../../writing/drafts/02_draft_05-08-21/graphics/ssax_boxplot.tex",
     width = plot_width,
     height = plot_height)

boxplot(recall ~ as.factor(rank), 
        data = d,
        main = "Boxplot of Recall for 10 best S-SAX Parameter Sets",
        xlab = "Rank",
        ylab = "Recall",
        ylim = c(0, 1),
        col = c("gray", "red")
        )
dev.off()


best_ssax <- ssax_data[8, ]

# DSAX BOXPLOT
actual_data <- actual_dsax
ran <- 1:10
summary <- dsax_data[ran, 1:4]
d <- data.frame()
iqrs <- c(NA)
length(iqrs) <- 10
ranks <- c(NA)
length(ranks) <- 10
num_ol <- c(NA)
length(num_ol) <- 10
for (i in ran) {
    ecgs <- get_ecgs(actual_data, summary[i, ])
    d <- rbind(d, cbind(ecgs, data.frame(rank = rep(i, 48))))
    iqrs[i] <- IQR(ecgs$recall)
    ranks[i] <- i
    num_ol[i] <- sum(ecgs$recall < quantile(ecgs$recall)[2] - 1.5 * iqrs[i])
}
iqr_rank <- data.frame(rank = ranks, iqr_val = iqrs, outliers = num_ol)
iqr_rank <- iqr_rank[order(iqr_rank$iqr_val), ]
boxplot(recall ~ as.factor(rank), 
        data = d,
        main = "Boxplot of Recall for 10 best D-SAX Parameter Sets",
        xlab = "Rank",
        ylab = "Recall",
        ylim = c(0, 1)
        )

best_dsax <- dsax_data[7, ]

# MSAX BOXPLOT
actual_data <- actual_msax
ran <- 1:10
summary <- msax_data[ran, 1:4]
d <- data.frame()
iqrs <- c(NA)
length(iqrs) <- 10
ranks <- c(NA)
length(ranks) <- 10
num_ol <- c(NA)
length(num_ol) <- 10
for (i in ran) {
    ecgs <- get_ecgs(actual_data, summary[i, ])
    d <- rbind(d, cbind(ecgs, data.frame(rank = rep(i, 48))))
    iqrs[i] <- IQR(ecgs$recall)
    ranks[i] <- i
    num_ol[i] <- sum(ecgs$recall < quantile(ecgs$recall)[2] - 1.5 * iqrs[i])
}
iqr_rank <- data.frame(rank = ranks, iqr_val = iqrs, outliers = num_ol)
iqr_rank <- iqr_rank[order(iqr_rank$iqr_val), ]
boxplot(recall ~ as.factor(rank), 
        data = d,
        main = "Boxplot of Recall for 10 best MSAX Parameter Sets",
        xlab = "Rank",
        ylab = "Recall",
        ylim = c(0, 1)
        )

best_msax <- msax_data[8, ]

ac_ssax <- get_ecgs(actual_ssax, best_ssax[,1:4])[,8:10]
ac_dsax <- get_ecgs(actual_dsax, best_dsax[,1:4])[,8:10]
ac_msax <- get_ecgs(actual_msax, best_msax[,1:4])[,8:10]
ac_combined <- rbind(ac_ssax, ac_dsax, ac_msax)

methods = c(rep("S-SAX", dim(ac_ssax)[1]), rep("D-SAX", dim(ac_dsax)[1]), rep("MSAX", dim(ac_msax)[1]))


best_comparison <- data.frame(ac_combined, method = methods)

# RECALL BOXPLOT
boxplot(recall ~ as.factor(method), 
        data = best_comparison,
        main = "Boxplot of Recall by Method for Optimal Parameters",
        ylab = "Recall",
        # ylim = c(0,1),
        xlab = "Method"
        )
boxplot(precision ~ as.factor(method), data = best_comparison)
boxplot(accuracy ~ as.factor(method), data = best_comparison)

# statistical measures SSAX
median(ac_ssax$recall)
IQR(ac_ssax$recall)
sum(ac_ssax$recall < quantile(ac_ssax$recall)[2] - 1.5 * IQR(ac_ssax$recall))

# statistical measures DSAX
median(ac_dsax$recall)
IQR(ac_dsax$recall)
sum(ac_dsax$recall < quantile(ac_dsax$recall)[2] - 1.5 * IQR(ac_dsax$recall))

# statistical measures MSAX
median(ac_msax$recall)
IQR(ac_msax$recall)
sum(ac_msax$recall < quantile(ac_msax$recall)[2] - 1.5 * IQR(ac_msax$recall))

# correlation analysis
methods = c(rep(0, dim(ac_ssax)[1]), rep(1, dim(ac_dsax)[1]), rep(2, dim(ac_msax)[1]))
best_comparison <- data_frame(best_comparison, method_num = )

ssax_vs_dsax <- best_comparison[best_comparison$method != "MSAX",]
ssax_vs_dsax <-
    data.frame(ssax_vs_dsax, method_num = c(rep(0, dim(ac_ssax)[1]), rep(1, dim(ac_dsax)[1])))
cor(ssax_vs_dsax$recall, ssax_vs_dsax$method_num)
cor(ssax_vs_dsax$recall, ssax_vs_dsax$method_num, method = "kendall")
cor(ssax_vs_dsax$recall, ssax_vs_dsax$method_num, method = "spearman")
                                  
ssax_vs_msax <- best_comparison[best_comparison$method != "D-SAX",]
ssax_vs_msax <-
    data.frame(ssax_vs_msax, method_num = c(rep(0, dim(ac_ssax)[1]), rep(1, dim(ac_msax)[1])))
cor(ssax_vs_msax$recall, ssax_vs_msax$method_num)
cor(ssax_vs_msax$recall, ssax_vs_msax$method_num, method = "kendall")
cor(ssax_vs_msax$recall, ssax_vs_msax$method_num, method = "spearman")

dsax_vs_msax <- best_comparison[best_comparison$method != "S-SAX",]
dsax_vs_msax <-
    data.frame(dsax_vs_msax, method_num = c(rep(0, dim(ac_dsax)[1]), rep(1, dim(ac_msax)[1])))
cor(dsax_vs_msax$recall, dsax_vs_msax$method_num)
cor(dsax_vs_msax$recall, dsax_vs_msax$method_num, method = "kendall")
cor(dsax_vs_msax$recall, dsax_vs_msax$method_num, method = "spearman")
                                 
                                  
                                  
                                  
                                  
                                  
                                  
                                  
                                  
                                  
                                  

# outliers occur ssax, msax, dsax
# very clear pattern to them -> needs investigation
# -> write ECG code into files and then check?
# could also just run for 1, take that and compute values from it

# indicates that for the top 10, the values are basically identical
# this means that we can pick one that has the highest dim reduction
# or something

ssax_test <- ssax_data[1, 1:4]
dsax_test <- dsax_data[1, 1:4]
msax_test <- msax_data[1, 1:4]

outlier_data <- read.csv2("./outlier_data/data-beat_types-FALSE--single-FALSE--first_sax-FALSE.csv")
outlier_msax <- outlier_data[outlier_data$is_msax == 1, ]
outlier_dsax <- outlier_data[outlier_data$is_msax == 0, ]
outlier_data <- read.csv2("./outlier_data/data-beat_types-FALSE--single-TRUE--first_sax-FALSE.csv")
outlier_ssax <- outlier_data[outlier_data$is_msax == 0, ]
outlier_data <- read.csv2("./outlier_data/data-beat_types-FALSE--single-TRUE--first_sax-TRUE.csv")
outlier_ssax <- rbind(outlier_ssax, outlier_data[outlier_data$is_msax == 0, ])

ssax_outliers <- get_ecgs(outlier_ssax, ssax_test)
ssax_outliers <- (ssax_outliers[order(ssax_outliers$recall), ])[1:9, ]
dsax_outliers <- get_ecgs(outlier_dsax, dsax_test)
dsax_outliers <- (dsax_outliers[order(dsax_outliers$recall), ])[1:3, ]
msax_outliers <- get_ecgs(outlier_msax, msax_test)
msax_outliers <- (msax_outliers[order(msax_outliers$recall), ])[1:5, ]

# top 9 outliers for ssax: 102 117 200 122 109 103 121 109 101
# top 3 outliers for dsax: 109 119 207
# top 5 outliers for msax: 117 109 102 119 200

# look at all the things and try to find explanations. especially the 
# ones shared between more than one approach.









msax_data <- read.csv2("./data/no_sub-single_sax-summary_msax.csv")
sax_data <- read.csv2("./data/no_sub-single_sax-summary_sax.csv")

sax_data <- sax_data[order(sax_data$recall, decreasing = T),]
st1 <- sax_data[1:25,]

msax_data <- msax_data[order(msax_data$recall, decreasing = T),]
sm1 <- msax_data[1:25, ]

test <- rbind(st1, sm1)
test <- data.frame(test, is_msax = c(rep(0, dim(sm1)[1]), rep(1, dim(st1)[1])))

cor(test$recall, test$is_msax)
cor.test(test$recall, test$is_msax)


msax_data <- read.csv2("./data/sub-dual_sax-summary_msax.csv")
sax_data <- read.csv2("./data/sub-dual_sax-summary_sax.csv")

sax_data <- sax_data[order(sax_data$recall, decreasing = T),]
st1 <- sax_data[1:25,]

msax_data <- msax_data[order(msax_data$recall, decreasing = T),]
sm1 <- msax_data[1:25, ]

test <- rbind(st1, sm1)
test <- data.frame(test, is_msax = c(rep(0, dim(sm1)[1]), rep(1, dim(st1)[1])))

cor(test$recall, test$is_msax)
cor.test(test$recall, test$is_msax)

msax_data <- read.csv2("./data/sub-single_sax-summary_msax.csv")
sax_data <- read.csv2("./data/sub-single_sax-summary_sax.csv")

sax_data <- sax_data[order(sax_data$recall, decreasing = T),]
st1 <- sax_data[1:25,]

msax_data <- msax_data[order(msax_data$recall, decreasing = T),]
sm1 <- msax_data[1:25, ]

test <- rbind(st1, sm1)
test <- data.frame(test, is_msax = c(rep(0, dim(sm1)[1]), rep(1, dim(st1)[1])))

cor(test$recall, test$is_msax)
cor.test(test$recall, test$is_msax)

data <- read.csv2("./data/sub-dual_sax-summary_msax.csv")
unique(data$k)
unique(data$paa_count)
unique(data$subsequence)
unique(data$alphabet_size)

data <- data[order(data$recall, decreasing = T), ]
s2 <- data[data$k > 0, ]
cor(s2$recall, s2$k)
s1 <- data[order(data$recall, decreasing = T), ]
s3 <- s1[s1$paa_count != s1$subsequence, ]
cor(s2$recall, s2$subsequence)

data <- read.csv2("./data/no_sub-single_sax-summary_msax.csv")
# 
s1 <- data[data$recall >= 0.95, ]
s1 <- s1[order(s1$precision, decreasing = T), ][1:10, ]

data <- read.csv2("./data/no_sub-single_sax-summary_sax.csv")

s2 <- data[data$recall >= 0.95, ]
s2 <- s2[order(s2$precision, decreasing = T), ][1:10, ]

data <- read.csv2("./data/no_sub-dual_sax-summary_sax.csv")

s3 <- data[data$recall >= 0.95, ]
s3 <- s3[order(s3$precision, decreasing = T), ][1:10, ]

ss <- read.csv2("./real_test_1/data-beat_types-FALSE--single-FALSE--first_sax-FALSE.csv")

ss1 <- ss[ss$is_msax == 1, ]
ss1 <- ss1[ss1$k == -1 & ss1$paa_segment_count == 6 & ss1$alphabet_size == 24, ]

ss2 <- ss[ss$is_msax == 0, ]
ss2 <- ss2[ss2$k == -1 & ss2$paa_segment_count == 12 & ss2$alphabet_size == 22, ]

ss3 <- ss[ss$k == -1 & ss$paa_segment_count == 6 & ss$alphabet_size == 24 & ss$is_msax==0, ]

p <- rbind(ss1, ss2)
q <- rbind(ss1, ss3)

boxplot(recall ~ as.factor(method), 
        data=p, 
        main = "Boxplot Comparing Recall for Dual SAX and MSAX",
        xlab = "Representation",
        ylab = "Recall"
    )

cor(p$recall, p$is_msax)
cor.test(p$recall, p$is_msax)

boxplot(precision ~ as.factor(method), 
        data=p, 
        main = "Boxplot Comparing Precision for Dual SAX and MSAX",
        xlab = "Representation",
        ylab = "Precision"
    )

cor(p$precision, p$is_msax)
cor.test(p$precision, p$is_msax)


# https://www.tutorialspoint.com/r/r_boxplots.htm