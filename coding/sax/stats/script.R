prepare_data <- function(with_beat_types, single_sax, sax_code) {
    if (with_beat_types) {
        if (single_sax) {
            get_sax_tn <- function(data) {
                return(dim(data[((data$annotations == "N" |
                                      data$annotations == "") &
                                     data$beats == "(N") &
                                    data$sax != sax_code, ])[1])
            }
            
            get_sax_tp <- function(data) {
                return(dim(data[((data$annotations != "N" &
                                      data$annotations != "") &
                                     data$beats != "(N") &
                                    data$sax == sax_code, ])[1])
            }
            
            get_sax_fp <- function(data) {
                return(dim(data[((data$annotations == "N" |
                                      data$annotations == "") &
                                     data$beats == "(N") &
                                    data$sax == sax_code, ])[1])
            }
            
            get_sax_fn <- function(data) {
                return(dim(data[((data$annotations != "N" &
                                      data$annotations != "") &
                                     data$beats != "(N") &
                                    data$sax != sax_code, ])[1])
            }
        } else {
            get_sax_tn <- function(data) {
                return(dim(data[((data$annotations == "N" |
                                      data$annotations == "") &
                                     data$beats == "(N") &
                                    data$sax == 0, ])[1])
            }
            
            get_sax_tp <- function(data) {
                return(dim(data[((data$annotations != "N" &
                                      data$annotations != "") &
                                     data$beats != "(N") &
                                    data$sax != 0, ])[1])
            }
            
            get_sax_fp <- function(data) {
                return(dim(data[((data$annotations == "N" |
                                      data$annotations == "") &
                                     data$beats == "(N") &
                                    data$sax != 0, ])[1])
            }
            
            get_sax_fn <- function(data) {
                return(dim(data[((data$annotations != "N" &
                                      data$annotations != "") &
                                     data$beats != "(N") &
                                    data$sax == 0, ])[1])
            }
            
        }
        
        get_msax_tn <- function(data) {
            return(dim(data[((data$annotations == "N" |
                                  data$annotations == "") &
                                 data$beats == "(N") &
                                data$msax == 0, ])[1])
        }
        
        get_msax_tp <- function(data) {
            return(dim(data[((data$annotations != "N" &
                                  data$annotations != "") &
                                 data$beats != "(N") &
                                data$msax != 0, ])[1])
        }
        
        get_msax_fp <- function(data) {
            return(dim(data[((data$annotations == "N" |
                                  data$annotations == "") &
                                 data$beats == "(N") &
                                data$msax != 0, ])[1])
        }
        
        get_msax_fn <- function(data) {
            return(dim(data[((data$annotations != "N" &
                                  data$annotations != "") &
                                 data$beats != "(N") &
                                data$msax == 0, ])[1])
        }
    } else {
        if (single_sax) {
            get_sax_tn <- function(data) {
                return(dim(data[(data$annotations == "N" |
                                     data$annotations == "") &
                                    data$sax != sax_code, ])[1])
            }
            
            get_sax_tp <- function(data) {
                return(dim(data[(data$annotations != "N" &
                                     data$annotations != "") &
                                    data$sax == sax_code, ])[1])
            }
            
            get_sax_fp <- function(data) {
                return(dim(data[(data$annotations == "N" |
                                     data$annotations == "") &
                                    data$sax == sax_code, ])[1])
            }
            
            get_sax_fn <- function(data) {
                return(dim(data[(data$annotations != "N" &
                                     data$annotations != "") &
                                    data$sax != sax_code, ])[1])
            }
        } else {
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
    }
    
    files <-
        list.files(
            path = "../processed_data/test_number_2/",
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
        
        sax.tn <- get_sax_tn(data)
        sax.tp <- get_sax_tp(data)
        sax.fp <- get_sax_fp(data)
        sax.fn <- get_sax_fn(data)
        
        sax.recalls[count] <- sax.tp / (sax.tp + sax.fn)
        sax.accuracy[count] <-
            (sax.tp + sax.tn) / (sax.tp + sax.tn + sax.fp + sax.fn)
        sax.precision[count] <- sax.tp / (sax.tp + sax.fp)
        sax.f1[count] <-
            2 * (sax.recalls[count] * sax.precision[count]) / (sax.recalls[count] + sax.precision[count])
        
        msax.tn <- get_msax_tn(data)
        msax.tp <- get_msax_tp(data)
        msax.fp <- get_msax_fp(data)
        msax.fn <- get_msax_fn(data)
        
        msax.recalls[count] <- msax.tp / (msax.tp + msax.fn)
        msax.accuracy[count] <-
            (msax.tp + msax.tn) / (msax.tp + msax.tn + msax.fp + msax.fn)
        msax.precision[count] <- msax.tp / (msax.tp + msax.fp)
        msax.f1[count] <-
            2 * (msax.recalls[count] * msax.precision[count]) / (msax.recalls[count] + msax.precision[count])
        
        k[count] <- data$k[1]
        paa_segment_count[count] <- data$paa_segments[1]
        subsequence_length[count] <- data$subsequence_count[1]
    }
    
    is_sax <-
        c(rep(1, length(msax.accuracy)[1]), rep(0, length(msax.accuracy)[1]))
    
    method <-
        c(rep("SAX", length(msax.accuracy)[1]), rep("MSAX", length(msax.accuracy)[1]))
    
    data <-
        data.frame(
            is_sax = is_sax,
            method = method,
            k = rep(k, 2),
            paa_segment_count = rep(paa_segment_count, 2),
            subsequence_length = rep(subsequence_length, 2),
            accuracy = c(as.vector(sax.accuracy), as.vector(msax.accuracy)),
            precision = c(as.vector(sax.precision),
                          as.vector(msax.precision)),
            recall = c(as.vector(sax.recalls), as.vector(msax.recalls)),
            f1 = c(as.vector(sax.f1), as.vector(msax.f1))
        )
    
    write.csv2(data,
               paste0("./data_summarized/data-b", with_beat_types, "-s", single_sax, "-c", sax_code, ".csv"))
}

prepare_data(T, T, 1)
prepare_data(F, T, 1)
 
prepare_data(T, T, 2)
prepare_data(F, T, 2)
 
prepare_data(F, F, 0)
prepare_data(T, F, 0)
