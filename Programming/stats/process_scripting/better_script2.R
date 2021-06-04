prepare_data <- function(with_beat_types, single_sax, is_first_sax, dirname) {
    first_sax_code <- 1
    second_sax_code <- 2
    both_sax_code <- first_sax_code + second_sax_code
    
    if (single_sax) {
        if (is_first_sax) {
            sax_code <- first_sax_code
        } else {
            sax_code <- second_sax_code
        }
    }
    
    files <-
        list.files(
            path = paste0("../processed_data/", dirname),
            pattern = "*.csv",
            full.names = TRUE,
            recursive = FALSE
        )
    
    len <- length(files)
    count <- 0
    
    sax.recalls <- c(NA)
    sax.accuracy <- c(NA)
    sax.precision <- c(NA)
    sax.f1 <- c(NA)
    length(sax.recalls) <- len
    length(sax.accuracy) <- len
    length(sax.precision) <- len
    length(sax.f1) <- len
    
    msax.recalls <- c(NA)
    msax.accuracy <- c(NA)
    msax.precision <- c(NA)
    msax.f1 <- c(NA)
    length(msax.recalls) <- len
    length(msax.accuracy) <- len
    length(msax.precision) <- len
    length(msax.f1) <- len
    
    k <- c(NA)
    length(k) <- len
    
    paa_segment_count <- c(NA)
    length(paa_segment_count) <- len
    
    subsequence_length <- c(NA)
    length(subsequence_length) <- len

    alphabet_size <- c(NA)
    length(alphabet_size) <- len
    
    for (file in files) {
        count <- count + 1
        print(paste(
            count,
            "of",
            len,
            " - ",
            round(100 * count / len, digits = 1),
            "%"
        ))
        
        data <- read.csv(file)
        
        if (with_beat_types) {
            normal_beat <- (data$annotations == "N" | data$annotations == "") & 
                            data$beats == "(N"
        } else {
            normal_beat <- data$annotations == "N" | data$annotations == ""
        }
        
        if (single_sax) {
            sax_found <- data$sax == sax_code | data$sax == both_sax_code
        } else {
            sax_found <- data$sax != 0
        }
        msax_found <- data$msax != 0
        
        sax.tn <- dim(data[normal_beat & !sax_found, ])[1]
        sax.tp <- dim(data[!normal_beat & sax_found, ])[1]
        sax.fp <- dim(data[normal_beat & sax_found, ])[1]
        sax.fn <- dim(data[!normal_beat & !sax_found, ])[1]
        
        msax.tn <- dim(data[normal_beat & !msax_found, ])[1]
        msax.tp <- dim(data[!normal_beat & msax_found, ])[1]
        msax.fp <- dim(data[normal_beat & msax_found, ])[1]
        msax.fn <- dim(data[!normal_beat & !msax_found, ])[1]
        
        sax.recalls[count] <- sax.tp / (sax.tp + sax.fn)
        sax.accuracy[count] <-
            (sax.tp + sax.tn) / (sax.tp + sax.tn + sax.fp + sax.fn)
        sax.precision[count] <- sax.tp / (sax.tp + sax.fp)
        sax.f1[count] <-
            2 * (sax.recalls[count] * sax.precision[count]) / (sax.recalls[count] + sax.precision[count])
        
        msax.recalls[count] <- msax.tp / (msax.tp + msax.fn)
        msax.accuracy[count] <-
            (msax.tp + msax.tn) / (msax.tp + msax.tn + msax.fp + msax.fn)
        msax.precision[count] <- msax.tp / (msax.tp + msax.fp)
        msax.f1[count] <-
            2 * (msax.recalls[count] * msax.precision[count]) / (msax.recalls[count] + msax.precision[count])
        
        k[count] <- data$k[1]
        paa_segment_count[count] <- data$paa_segments[1]
        subsequence_length[count] <- data$subsequence_count[1]
        alphabet_size[count] <- data$alphabet_size[1]
    }
    
    is_msax <-
        c(rep(0, length(msax.accuracy)[1]), rep(1, length(msax.accuracy)[1]))
    
    method <-
        c(rep("SAX", length(msax.accuracy)[1]), rep("MSAX", length(msax.accuracy)[1]))
    
    data <-
        data.frame(
            is_msax = is_msax,
            method = method,
            k = rep(k, 2),
            paa_segment_count = rep(paa_segment_count, 2),
            subsequence_length = rep(subsequence_length, 2),
            alphabet_size = rep(alphabet_size, 2),
            accuracy = c(as.vector(sax.accuracy), as.vector(msax.accuracy)),
            precision = c(as.vector(sax.precision),
                          as.vector(msax.precision)),
            recall = c(as.vector(sax.recalls), as.vector(msax.recalls)),
            f1 = c(as.vector(sax.f1), as.vector(msax.f1))
        )
    
    write.csv2(data,
               paste0("./data_summarized/data-beat_types-", with_beat_types, "--single-", single_sax, "--first_sax-", is_first_sax, ".csv"))
}

dirname <- "test_number_3/"

#prepare_data(T, T, T, dirname) 

#prepare_data(T, T, F, dirname)

prepare_data(F, T, T, dirname)

prepare_data(F, T, F, dirname)

#prepare_data(T, F, F, dirname)

#prepare_data(F, F, F, dirname)
