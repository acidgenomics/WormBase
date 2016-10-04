library(devtools)
library(dplyr)
library(magrittr)
library(readxl)
library(seqcloudr)
library(stringr)

fileLocal <- "data-raw/ahringer.xlsx"
if (!file.exists(fileLocal)) {
    download.file("http://www.us.lifesciences.sourcebioscience.com/media/381254/C.%20elegans%20Database%202012.xlsx",
                  fileLocal)
}
chromosomes <- c("I", "II", "III", "IV", "V", "X")
list <- list()
for (i in 1:length(chromosomes)) {
    # Note that the first sheet contains notes, so \code{i + 1}
    tbl <- readxl::read_excel(fileLocal, sheet = i + 1, col_types = rep("text", 8)) %>%
        magrittr::set_names(seqcloudr::camel(names(.))) %>%
        dplyr::filter(!grepl("mismatch", extraInfo)) %>%
        dplyr::select(-c(extraInfo, fwdPrimerSeq, revPrimerSeq)) %>%
        dplyr::rename(genePair = genePairsName,
                      ahringer384 = sourceBioscienceLocation) %>%
        dplyr::mutate(ahringer96 = paste0(plate, well),
                      ahringer96 = gsub("([A-Z]{1})0", "\\1", ahringer96),
                      ahringer384 = gsub("-", "", ahringer384),
                      ahringer384 = gsub("([A-Z]{1})0", "\\1", ahringer384)) %>%
        dplyr::select(-c(plate, well, chrom))
    name <- paste0("chr", chromosomes[i])
    list[[i]] <- tbl
}
ahringer <- dplyr::bind_rows(list) %>%
    arrange(genePair, ahringer384)
rm(chromosomes, i, list, name, tbl)
devtools::use_data(ahringer, overwrite = TRUE)
