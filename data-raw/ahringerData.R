library(dplyr)
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

# WBRNAi from WormBase historical experiments
if (file.exists("data/ahringerWbrnai.rda")) {
    data(ahringerWbrnai)
} else {
    ahringerWbrnai <- historical2wbrnai(raw$wormbaseHistorical)
    devtools::use_data(ahringerWbrnai, overwrite = TRUE)
}

# WormBase RESTful API requests with WBRNAi
if (file.exists("data/ahringerRest.rda")) {
    data(ahringerRest)
} else {
    # Split up to prevent curl memory error
    ahringerRest1 <- historical2wbrnai(ahringerRawData$historical[00001:05000])
    ahringerRest2 <- historical2wbrnai(ahringerRawData$historical[05001:10000])
    ahringerRest3 <- historical2wbrnai(ahringerRawData$historical[10001:15000])
    ahringerRest4 <- historical2wbrnai(ahringerRawData$historical[15001:nrow(ahringerRawData)])
    ahringerRest <- rbind(ahringerRest1, ahringerRest2, ahringerRest3, ahringerRest4)
    devtools::use_data(ahringerRest, overwrite = TRUE)
}

# Oligo to Gene ID
if (file.exists("data/oligo2geneId.rda")) {
    data(oligo2geneId)
} else {
    source("data-raw/oligo2geneId.R")
}

df <- cbind(ahringerRawData, ahringerRest)
df <- df[, unique(names(df))]
df <- merge(df, oligo2geneId, by = "oligo", all.x = TRUE)

oligoNoMatch <- dplyr::filter(df, is.na(df$geneId))
oligoNoMatch$geneId <- NULL

df <- dplyr::filter(df, !is.na(df$geneId))
df <- merge(df, gene(df$geneId, output = "simple"), by = "geneId", all.x = TRUE)
oligoMatch <- df

# Strip isoforms from genePair search
genePairQuery <- oligoNoMatch$genePair
genePairQuery[1:1000]
genePairQuery <- gsub("([0-9]+)[a-z]$", "\\1", genePairQuery)
genePairQuery[1:1000]
genePairQuery <- gsub("\\.([0-9]+)\\.[0-9]+$", ".\\1", genePairQuery)
df2 <- merge(oligoNoMatch,
             gene(genePairQuery, format = "orf", output = "simple"),
             by.x = "genePair", by.y = "orf",
             all.x = TRUE)

df2 <- merge(df2, gene(df$genePair, format = "orf", output = "simple"), all.x = TRUE)

ahringerData <- list(raw, wbrnai)
devtools::use_data(ahringerData, overwrite = TRUE)
```
