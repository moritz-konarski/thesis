library(ggplot2)
library(tikzDevice)

y <- exp(seq(1,10,.1))
x <- 1:length(y)

data <- data.frame(x = x, y = y)

tikz(file = "./test/graphics/test.tex")
a = runif(100)
boxplot(a)
dev.off()

tikz(file = "./test/graphics/test.tex",
     width = 6,
     height = 6)
a = runif(100)
b = runif(100) + 0.3
data <- data.frame(a, b)
ggplot(data, aes(x = a, y = b)) +
    geom_point() +
    labs(
        x = "$\\alpha$",
        y = "$\\beta$",
        title = "\\LaTeX{} test plot"
    ) + 
    geom_smooth(method = lm, se=F)
dev.off()

ggplot(data, aes(x = x, y = y)) + geom_line()

data <- read.csv2("./data_summarized/data-bFALSE-sFALSE-c0.csv")

tikz(file = "./test/test.tex")
p1 <- ggplot(data,
             aes(x = as.factor(paa_segment_count),
                 y = recall)) +
    geom_boxplot(outlier.shape = NA) +
    facet_grid(subsequence_length ~ paa_segment_count, scales = 'free')
dev.off()

unique(data$paa_segment_count)
# 2  3  4  5  6  8  9 10 15 18 20 24 30

paas <- c(2, 3, 4, 5, 6, 8, 9, 10, 15, 18, 20, 24, 30)

for (paa in paas) {
    subset <- data[data$paa_segment_count == paa,]
    subset$subsequence_length <- as.factor(subset$subsequence_length)
    subset$method <- as.factor(subset$method)
    
    pl <- ggplot(subset,
           aes(x = subsequence_length,
               y = recall,
               fill = method)) +
        geom_boxplot(outlier.shape = NA) +
        labs(
            x = "subsequence lengths",
            y = "Recall",
            fill = "Method",
            title = paste("Subs Len vs Recall for paa=", paa)
        )
    print(pl)
    
    readline()
}


subset <- data[data$paa_segment_count != 30, ]

ggplot(subset, aes(
           x = as.factor(subsequence_length),
           y = recall,
           fill = as.factor(method)
       )) +
    geom_boxplot() +
    labs(x = "subsequence lengths",
         y = "Recall",
         fill = "Method",
         title = "Recall for PAA Segment Counts and Subsequence Lengths") + 
    facet_wrap(vars(paa_segment_count), scales = "free")

ggplot(subset, aes(
    x = as.factor(subsequence_length),
    y = recall,
    fill = as.factor(method)
)) +
    geom_boxplot(outlier.shape = NA) +
    labs(x = "subsequence lengths",
         y = "Recall",
         fill = "Method",
         title = "Recall for PAA Segment Counts and Subsequence Lengths") + 
    facet_wrap(vars(paa_segment_count), scales = "free")


ss2 <- data[data$paa_segment_count == 24, ]
ggplot(ss2, aes(
    x = subsequence_length,
    y = recall,
    fill = as.factor(method)
)) +
    geom_point() +
    geom_smooth() +
    labs(x = "subsequence lengths",
         y = "Recall",
         fill = "Method",
         title = "Recall for PAA Segment Counts and Subsequence Lengths") +
    facet_wrap(vars(paa_segment_count))














library(plotly)

plot_ly(
    x = data$paa_segment_count,
    y = data$subsequence_length,
    z = data$recall,
    type = "scatter3d",
    mode = "markers",
    color = data$method
)

cor(data$subsequence_length, data$recall)
summary(lm(data$paa_segment_count ~ data$recall))

cor(data$recall, data$subsequence_length)
m0 <- lm(data$recall ~ data$subsequence_length)

cor(data$recall, data$paa_segment_count)
m1 <- lm(data$recall ~ data$paa_segment_count)

cor(data$recall, data$paa_segment_count)
m2 <- lm(data$recall ~ data$paa_segment_count + data$subsequence_length)


