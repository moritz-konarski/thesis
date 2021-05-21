
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

