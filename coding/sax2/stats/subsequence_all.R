library(ggplot2)

get_sax_tn <- function(data) {
    return(dim(data[(data$annotations == "N" |
                         data$annotations == "") &
                        data$sax == 0, ])[1])
}

get_sax_tp <- function(data) {
    return(dim(data[(data$annotations != "N" &
                         data$annotations != "") &
                        data$sax != 0, ])[1])
}

get_sax_fp <- function(data) {
    return(dim(data[(data$annotations == "N" |
                         data$annotations == "") &
                        data$sax != 0, ])[1])
}

get_sax_fn <- function(data) {
    return(dim(data[(data$annotations != "N" &
                         data$annotations != "") &
                        data$sax == 0, ])[1])
}

get_msax_tn <- function(data) {
    return(dim(data[(data$annotations == "N" |
                         data$annotations == "") &
                        data$msax == 0, ])[1])
}



get_msax_tp <- function(data) {
    return(dim(data[(data$annotations != "N" &
                         data$annotations != "") &
                        data$msax != 0, ])[1])
}



get_msax_fp <- function(data) {
    return(dim(data[(data$annotations == "N" |
                         data$annotations == "") &
                        data$msax != 0, ])[1])
}



get_msax_fn <- function(data) {
    return(dim(data[(data$annotations != "N" &
                         data$annotations != "") &
                        data$msax == 0, ])[1])
}


get_sax_accuracy <- function(data) {
    tp <- get_sax_tp(data)
    tn <- get_sax_tn(data)
    fn <- get_sax_fn(data)
    fp <- get_sax_fp(data)
    
    return((tp + tn) / (tp + tn + fp + fn))
}

get_msax_accuracy <- function(data) {
    tp <- get_msax_tp(data)
    tn <- get_msax_tn(data)
    fn <- get_msax_fn(data)
    fp <- get_msax_fp(data)
    
    return((tp + tn) / (tp + tn + fp + fn))
}

get_sax_recall <- function(data) {
    tp <- get_sax_tp(data)
    fn <- get_sax_fn(data)
    
    return(tp / (tp + fn))
}

get_msax_recall <- function(data) {
    tp <- get_msax_tp(data)
    fn <- get_msax_fn(data)
    
    return(tp / (tp + fn))
}

get_sax_precision <- function(data) {
    tp <- get_sax_tp(data)
    fp <- get_sax_fp(data)
    
    return(tp / (tp + fp))
}

get_msax_precision <- function(data) {
    tp <- get_msax_tp(data)
    fp <- get_msax_fp(data)
    
    return(tp / (tp + fp))
}

get_sax_f1 <- function(data) {
    recall <- get_sax_recall(data)
    precision <- get_sax_precision(data)
    
    return(2 * (recall * precision) / (recall + precision))
}

get_msax_f1 <- function(data) {
    recall <- get_msax_recall(data)
    precision <- get_msax_precision(data)
    
    return(2 * (recall * precision) / (recall + precision))
}

types <- c(3, 6, 9, 12, 15, 18)

type.sax.recalls <- cbind()
type.sax.precision <- cbind()
type.sax.accuracy <- cbind()
type.sax.f1 <- cbind()

type.msax.recalls <- cbind()
type.msax.precision <- cbind()
type.msax.accuracy <- cbind()
type.msax.f1 <- cbind()

for (type in types) {
    files <-
        list.files(
            path = paste0("../processed_data/subsequence_length/", type),
            pattern = "*.csv",
            full.names = TRUE,
            recursive = FALSE
        )
    
    sax.recalls <- c()
    sax.accuracy <- c()
    sax.precision <- c()
    sax.f1 <- c()
    
    msax.recalls <- c()
    msax.accuracy <- c()
    msax.precision <- c()
    msax.f1 <- c()
    
    for (file in files) {
        data <- read.csv(file)
        
        sax.recalls <- c(sax.recalls, get_sax_recall(data))
        sax.accuracy <- c(sax.accuracy, get_sax_accuracy(data))
        sax.precision <- c(sax.precision, get_sax_precision(data))
        sax.f1 <- c(sax.f1, get_sax_f1(data))
        
        msax.recalls <- c(msax.recalls, get_msax_recall(data))
        msax.accuracy <- c(msax.accuracy, get_msax_accuracy(data))
        msax.precision <-
            c(msax.precision, get_msax_precision(data))
        msax.f1 <- c(msax.f1, get_msax_f1(data))
    }
    
    type.sax.recalls <- cbind(type.sax.recalls, sax.recalls)
    type.sax.precision <- cbind(type.sax.precision, sax.precision)
    type.sax.accuracy <- cbind(type.sax.accuracy, sax.accuracy)
    type.sax.f1 <- cbind(type.sax.f1, sax.f1)
    
    type.msax.recalls <- cbind(type.msax.recalls, msax.recalls)
    type.msax.precision <-
        cbind(type.msax.precision, msax.precision)
    type.msax.accuracy <- cbind(type.msax.accuracy, msax.accuracy)
    type.msax.f1 <- cbind(type.msax.f1, msax.f1)
}

colnames(type.sax.recalls) <- paste0(types)
colnames(type.sax.precision) <- paste0(types)
colnames(type.sax.accuracy) <- paste0(types)
colnames(type.sax.f1) <- paste0(types)

colnames(type.msax.recalls) <- paste0(types)
colnames(type.msax.precision) <- paste0(types)
colnames(type.msax.accuracy) <- paste0(types)
colnames(type.msax.f1) <- paste0(types)

type_col <- rep(types, each = dim(type.msax.accuracy)[1])
is_sax <- c(rep(1, length(type_col)), rep(0, length(type_col)))
type_col <- rep(type_col, 2)

data <-
    data.frame(
        type = as.factor(type_col),
        is_sax = is_sax,
        accuracy = c(as.vector(type.sax.accuracy), as.vector(type.msax.accuracy)),
        precision = c(
            as.vector(type.sax.precision),
            as.vector(type.msax.precision)
        ),
        recall = c(as.vector(type.sax.recalls), as.vector(type.msax.recalls)),
        f1 = c(as.vector(type.sax.f1), as.vector(type.msax.f1))
    )

acc_plot <-
    ggplot(data, aes(
        x = type,
        y = accuracy,
        fill = as.factor(is_sax)
    )) +
    geom_boxplot() +
    labs(title = paste0(
        "Accuracy ",
        cor(data$is_sax, data$precision, use = "complete.obs")
    ))

prec_plot <-
    ggplot(data, aes(
        x = type,
        y = precision,
        fill = as.factor(is_sax)
    )) +
    geom_boxplot() +
    labs(title = paste0(
        "Precision ",
        cor(data$is_sax, data$precision, use = "complete.obs")
    ))

rec_plot <-
    ggplot(data, aes(
        x = type,
        y = recall,
        fill = as.factor(is_sax)
    )) +
    geom_boxplot() +
    labs(title = paste0("Recall ", cor(data$is_sax, data$recall, use = "complete.obs")))

f1_plot <-
    ggplot(data, aes(
        x = type,
        y = f1,
        fill = as.factor(is_sax)
    )) +
    geom_boxplot() +
    labs(title = paste0("F1 ", cor(data$is_sax, data$f1, use = "complete.obs")))

summary(lm(data$is_sax ~ data$accuracy))
summary(lm(data$is_sax ~ data$precision))
summary(lm(data$is_sax ~ data$recall))
summary(lm(data$is_sax ~ data$f1))
