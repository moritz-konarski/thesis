# data <- read.csv("../processed_data/MIT-BIH-24-24-10-150_108.csv")
data <- read.csv("../processed_data/MIT-BIH-24-24-10-150_100.csv")

# write function to read the files
# put each file type in own directory
# perform sax analysis on a lead by lead basis

library(ggplot2)

# TODO: figure out what to do about the empty segments: how can they be counted
# because some of the ones identified would probably be connected, but cannot be shown

sax.tn <-
    data[(data$annotations == "N" |
              data$annotations == "") & data$sax == 0, ]
sax.tn.count <- dim(sax.tn)[1]

sax.tp <-
    data[(data$annotations != "N" &
              data$annotations != "") & data$sax != 0, ]
sax.tp.count <- dim(sax.tp)[1]

sax.fp <-
    data[(data$annotations == "N" |
              data$annotations == "") & data$sax != 0, ]
sax.fp.count <- dim(sax.fp)[1]

sax.fn <-
    data[(data$annotations != "N" &
              data$annotations != "") & data$sax == 0, ]
sax.fn.count <- dim(sax.fn)[1]


msax.tn <-
    data[(data$annotations == "N" |
              data$annotations == "") & data$msax == 0, ]
msax.tn.count <- dim(msax.tn)[1]

msax.tp <-
    data[(data$annotations != "N" &
              data$annotations != "") & data$msax != 0, ]
msax.tp.count <- dim(msax.tp)[1]

msax.fp <-
    data[(data$annotations == "N" |
              data$annotations == "") & data$msax != 0, ]
msax.fp.count <- dim(msax.fp)[1]

msax.fn <-
    data[(data$annotations != "N" &
              data$annotations != "") & data$msax == 0, ]
msax.fn.count <- dim(msax.fn)[1]


sax.acc <-
    (sax.tp.count + sax.tn.count) / (sax.fn.count + sax.fp.count + sax.tp.count + sax.tn.count)

msax.acc <-
    (msax.tp.count + msax.tn.count) / (msax.fn.count + msax.fp.count + msax.tp.count + msax.tn.count)


sax.recall <- sax.tp.count / (sax.tp.count + sax.fn.count)

msax.recall <- msax.tp.count / (msax.tp.count + msax.fn.count)


sax.precision <- sax.tp.count / (sax.tp.count + sax.fp.count)

msax.precision <- msax.tp.count / (msax.tp.count + msax.fp.count)


sax.f1 <-
    2 * sax.recall * sax.precision / (sax.precision + sax.recall)

msax.f1 <-
    2 * msax.recall * msax.precision / (msax.precision + msax.recall)


acc <- paste(
    "Accuracy: ",
    round(sax.acc, digits = 5),
    "->",
    round(msax.acc, digits = 5)
)

rec <- paste(
    "Recall:   ",
    round(sax.recall, digits = 5),
    "->",
    round(msax.recall, digits = 5)
)

pre <- paste(
    "Precision:",
    round(sax.precision, digits = 5),
    "->",
    round(msax.precision, digits = 5)
)

f1 <- paste("F1:       ", round(sax.f1, digits = 5), "->", round(msax.f1, digits =
                                                              5))

print(acc)
print(rec)
print(pre)
print(f1)

