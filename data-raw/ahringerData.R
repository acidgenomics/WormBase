library(dplyr)
library(magrittr)
library(readxl)
library(seqcloudr)
library(tibble)
devtools::load_all()

if (!file.exists("data-raw/ahringer.xlsx")) {
    download.file("http://www.us.lifesciences.sourcebioscience.com/media/381254/C.%20elegans%20Database%202012.xlsx",
                  "data-raw/ahringer.xlsx")
}

chromosomes <- c("I", "II", "III", "IV", "V", "X")
list <- list()
for (i in 1:length(chromosomes)) {
    tbl <- read_excel("data-raw/ahringer.xlsx", sheet = i + 1) %>% # First sheet contains notes
        setNames(camel(names(.))) %>%
        select(-extraInfo) %>%
        rename(genePair = genePairsName, sourceBioscience384 = sourceBioscienceLocation) %>%
        mutate(wormbaseHistorical = paste0("JA:", genePair)) %>%
        mutate(fwdPrimerSeq = tolower(fwdPrimerSeq), revPrimerSeq = tolower(revPrimerSeq)) %>%
        #! df$plate <- stringr::str_pad(df$plate, 3, pad = "0")
        mutate(ahringer96 = do.call(paste, c(.[, c("chrom", "plate", "well")], sep = "-"))) %>%
        #! mutate(ahringer96 = gsub("-([A-Z]{1}[0-9]{2})$", "@\\1", ahringer96)) %>%
        select(-c(plate, well, chrom))
    name <- paste0("chr", chromosomes[i])
    list[[i]] <- tbl
}
rm(i, name, tbl)
raw <- as_tibble(do.call("rbind", list))
rm(list)

data(ahringerWbrnai)
if (!exists("ahringerWbrnai")) {
    ahringerWbrnai <- historical2wbrnai(raw$wormbaseHistorical)
    devtools::use_data(ahringerWbrnai, overwrite = TRUE)
}

data(ahringerSequence)
if (!exists("ahringerSequence")) {
    ahringerSequence1 <- wormbaseRestRnaiSequence(ahringerWbrnai$wbrnai[00001:05000])
    ahringerSequence2 <- wormbaseRestRnaiSequence(ahringerWbrnai$wbrnai[05001:10000])
    ahringerSequence3 <- wormbaseRestRnaiSequence(ahringerWbrnai$wbrnai[10001:15000])
    ahringerSequence4 <- wormbaseRestRnaiSequence(ahringerWbrnai$wbrnai[15001:nrow(ahringerWbrnai)])
    ahringerSequence <- bind_rows(ahringerSequence1,
                                  ahringerSequence2,
                                  ahringerSequence3,
                                  ahringerSequence4)
    devtools::use_data(ahringerSequence, overwrite = TRUE)
}

data(ahringerTargets)
if (!exists("ahringerTargets")) {
    ahringerTargets1 <- wormbaseRestRnaiTargets(ahringerWbrnai$wbrnai[00001:05000])
    ahringerTargets2 <- wormbaseRestRnaiTargets(ahringerWbrnai$wbrnai[05001:10000])
    ahringerTargets3 <- wormbaseRestRnaiTargets(ahringerWbrnai$wbrnai[10001:15000])
    ahringerTargets4 <- wormbaseRestRnaiTargets(ahringerWbrnai$wbrnai[15001:nrow(ahringerWbrnai)])
    ahringerTargets <- bind_rows(ahringerTargets1,
                                  ahringerTargets2,
                                  ahringerTargets3,
                                  ahringerTargets4)
    devtools::use_data(ahringerTargets, overwrite = TRUE)
}

data(oligo2geneId)
if (!exists("oligo2geneId")) {
    source("data-raw/oligo2geneId.R")
}

ahringerData <- left_join(ahringerWbrnai, ahringerSequence) %>%
    left_join(., ahringerTargets) %>%
    left_join(., oligo2geneId) %>%
    left_join(raw, .) %>%
    distinct %>%
    rename(primaryTarget = primary,
           secondaryTarget = secondary) %>%
    select(-wormbaseHistorical) %>%
    arrange(ahringer96)
devtools::use_data(ahringerData, overwrite = TRUE)
