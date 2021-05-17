# rerun the analysis, making sure that a specific sax also counts all the c1+c2
# points, as they were counted by each of the saxs
# try to vectorize the analysis

data1 <- read.csv2("./data_summarized2/data-bFALSE-sTRUE-c1.csv")

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
# TODO: 2D plot of parameter combinations as a type of heatmap
# TODO: combine all datasets and data collections together for the big analysis

cor(data$recall, data$is_sax)
# -> negative correlation -> what I intend to show -> -0.25
cor.test(data$recall, data$is_sax)
# t-value = -164 -> pretty damn significant

s <- data1[data1$k == -1 & data1$paa_segment_count == 12, ]
cor(s$recall, s$is_sax)
# -> negative correlation -> what I intend to show -> -0.25
cor.test(s$recall, s$is_sax)
# t-value = -164 -> pretty damn significant

# correlation between recall and k
cor(data1$recall, data1$k)
# -> tiny negative correlation
cor.test(data1$recall, data1$k)
# t-values small-ish, barely relevant
# TODO: take care, k=-1 is actually the biggest value

# correlation between recall and k
cor(data1$recall, data1$paa_segment_count)
# -> no correlation for this general test
cor.test(data1$recall, data1$paa_segment_count)
# t-values > 67 -> significant for any confidence interval

s1 <- data1[data1$k == -1, ]
# correlation between recall and k
cor(s1$recall, s1$paa_segment_count)
# -> 0.25 factor, is better than thought
cor.test(s1$recall, s1$paa_segment_count)
# t-values > 67 -> significant for any confidence interval

# TODO: run a bunch of these test for all possible values and then compare
