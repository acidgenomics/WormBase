library(dplyr)
library(readr)
library(seqcloudr)
load("data-raw/ahringer.rda")
if (!exists("ahringer")) {
    ahringer <- list()
}
if (!file.exists("data-raw/ahringer.xlsx")) {
    download.file("http://www.us.lifesciences.sourcebioscience.com/media/381254/C.%20elegans%20Database%202012.xlsx",
                  "data-raw/ahringer.xlsx")
}
if (is.null(ahringer$raw)) {
    chromosomes <- c("I", "II", "III", "IV", "V", "X")
    list <- list()
    for (i in 1:length(chromosomes)) {
        tbl <- read_excel("data-raw/ahringer.xlsx", sheet = i + 1,
                          col_types = rep("text", 8)) %>% # First sheet contains notes
            set_names(seqcloudr::camel(names(.))) %>%
            select(-c(extraInfo, fwdPrimerSeq, revPrimerSeq)) %>%
            rename(genePair = genePairsName,
                   ahringer384 = sourceBioscienceLocation) %>%
            mutate(historical = paste0("JA:", genePair),
                   plate = gsub("^S([0-9]{1})-", "S0\\1-", plate),
                   ahringer96 = paste(stringr::str_pad(plate, 3, pad = "0"), well, sep = "-"),
                   ahringer96 = gsub("^.*NA.*$", NA, ahringer96),
                   ahringer384 = gsub("-([0-9}+)([A-Z]{1})", "-\\1-\\2", ahringer384),
                   ahringer384 = gsub("-([0-9]{1})-", "-00\\1-", ahringer384),
                   ahringer384 = gsub("-([0-9]{2})-", "-0\\1-", ahringer384)) %>%
            select(-c(plate, well, chrom))
        name <- paste0("chr", chromosomes[i])
        list[[i]] <- tbl
    }
    ahringer[["raw"]] <- bind_rows(list)
    rm(chromosomes, i, list, name, tbl)
}
if (is.null(ahringer$wbrnai)) {
    ahringer[["wbrnai"]] <- historical2wbrnai(ahringer$raw$historical)
}
if (is.null(ahringer$sequence)) {
    rest1 <- wormbaseRestRnaiSequence(ahringer$wbrnai$wbrnai[00001:05000])
    rest2 <- wormbaseRestRnaiSequence(ahringer$wbrnai$wbrnai[05001:10000])
    rest3 <- wormbaseRestRnaiSequence(ahringer$wbrnai$wbrnai[10001:15000])
    rest4 <- wormbaseRestRnaiSequence(ahringer$wbrnai$wbrnai[15001:nrow(ahringer$wbrnai)])
    ahringer$sequence <- bind_rows(rest1, rest2, rest3, rest4)
    rm(rest1, rest2, rest3, rest4)
}
if (is.null(ahringer$targets)) {
    rest1 <- wormbaseRestRnaiTargets(ahringer$wbrnai$wbrnai[00001:05000])
    rest2 <- wormbaseRestRnaiTargets(ahringer$wbrnai$wbrnai[05001:10000])
    rest3 <- wormbaseRestRnaiTargets(ahringer$wbrnai$wbrnai[10001:15000])
    rest4 <- wormbaseRestRnaiTargets(ahringer$wbrnai$wbrnai[15001:nrow(ahringerWbrnai)])
    ahringer$targets <- bind_rows(rest1, rest2, rest3, rest4)
    rm(rest1, rest2, rest3, rest4)
}
save(ahringer, file = "data-raw/ahringer.rda")
