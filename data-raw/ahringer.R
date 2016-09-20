library(dplyr)
library(magrittr)
library(readxl)
library(seqcloudr)
library(stringr)
if (!file.exists("data-raw/ahringer.xlsx")) {
    download.file("http://www.us.lifesciences.sourcebioscience.com/media/381254/C.%20elegans%20Database%202012.xlsx",
                  "data-raw/ahringer.xlsx")
}
chromosomes <- c("I", "II", "III", "IV", "V", "X")
list <- list()
for (i in 1:length(chromosomes)) {
    # Note that the first sheet contains notes, so \code{i + 1}
    tbl <- readxl::read_excel("data-raw/ahringer.xlsx", sheet = i + 1, col_types = rep("text", 8)) %>%
        magrittr::set_names(seqcloudr::camel(names(.))) %>%
        dplyr::filter(!grepl("mismatch", extraInfo)) %>%
        dplyr::select(-c(extraInfo, fwdPrimerSeq, revPrimerSeq)) %>%
        dplyr::rename(genePair = genePairsName,
                      ahringer384 = sourceBioscienceLocation) %>%
        dplyr::mutate(plate = gsub("^S([0-9]{1})-", "S0\\1-", plate),
                      ahringer96 = paste(stringr::str_pad(plate, 3, pad = "0"), well, sep = "-"),
                      ahringer96 = gsub("^.*NA.*$", NA, ahringer96),
                      ahringer384 = gsub("-([0-9}+)([A-Z]{1})", "-\\1-\\2", ahringer384),
                      ahringer384 = gsub("-([0-9]{1})-", "-00\\1-", ahringer384),
                      ahringer384 = gsub("-([0-9]{2})-", "-0\\1-", ahringer384)) %>%
        dplyr::select(-c(plate, well, chrom))
    name <- paste0("chr", chromosomes[i])
    list[[i]] <- tbl
}
ahringer <- dplyr::bind_rows(list)
rm(chromosomes, i, list, name, tbl)
save(ahringer, file = "data-raw/ahringer.rda")
