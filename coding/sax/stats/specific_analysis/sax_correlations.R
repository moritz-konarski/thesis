# rerun the analysis, making sure that a specific sax also counts all the c1+c2
# points, as they were counted by each of the saxs
# try to vectorize the analysis

data1 <- read.csv2("./data_summarized2/data-bFALSE-sTRUE-c1.csv")
data2 <- read.csv2("./data_summarized2/data-bFALSE-sTRUE-c2.csv")

data1 <- data1[data1$is_sax == 1, ]
data2 <- data2[data2$is_sax == 1, ]

names(data1)

# k
# paa_count
# subseq_len
# method
# is_sax
# accuracy
# recall
# precision
# f1

# correlation between recall and k
cor(data1$recall, data1$k)
cor(data2$recall, data2$k)
# -> small correlations
cor.test(data1$recall, data1$k)
cor.test(data2$recall, data2$k)
# t-values > 67 -> significant for any confidence interval
# TODO: take care, k=-1 is actually the biggest value

# correlation between recall and k
cor(data1$recall, data1$paa_segment_count)
cor(data2$recall, data2$paa_segment_count)
# -> no correlation for this general test
cor.test(data1$recall, data1$paa_segment_count)
cor.test(data2$recall, data2$paa_segment_count)
# t-values > 67 -> significant for any confidence interval

s1 <- data1[data1$k == -1, ]
s2 <- data2[data2$k == -1, ]
# correlation between recall and k
cor(s1$recall, s1$paa_segment_count)
cor(s2$recall, s2$paa_segment_count)
# -> slighly negatively correlated 
cor.test(s1$recall, s1$paa_segment_count)
cor.test(s2$recall, s2$paa_segment_count)
# t-values > 67 -> significant for any confidence interval

# TODO: run a bunch of these test for all possible values and then compare
