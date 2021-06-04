
msax_data <- read.csv2("./data/no_sub-dual_sax-summary_msax.csv")
sax_data <- read.csv2("./data/no_sub-dual_sax-summary_sax.csv")

sax_data <- sax_data[order(sax_data$recall, decreasing = T),]
st1 <- sax_data[1:25,]

msax_data <- msax_data[order(msax_data$recall, decreasing = T),]
sm1 <- msax_data[1:25, ]

test <- rbind(st1, sm1)
test <- data.frame(test, is_msax = c(rep(0, dim(sm1)[1]), rep(1, dim(st1)[1])))

cor(test$recall, test$is_msax)
cor.test(test$recall, test$is_msax)


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