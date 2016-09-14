library(dplyr)
library(magrittr)
library(readxl)
library(seqcloudr)
library(stringr)
devtools::load_all()

# Ahringer ====
if (!file.exists("data-raw/ahringer.xlsx")) {
    download.file("http://www.us.lifesciences.sourcebioscience.com/media/381254/C.%20elegans%20Database%202012.xlsx",
                  "data-raw/ahringer.xlsx")
}
chromosomes <- c("I", "II", "III", "IV", "V", "X")
list <- list()
for (i in 1:length(chromosomes)) {
    tbl <- read_excel("data-raw/ahringer.xlsx", sheet = i + 1,
                      col_types = rep("text", 8)) %>% # First sheet contains notes
        set_names(camel(names(.))) %>%
        filter(!grepl("mismatch", extraInfo)) %>%
        select(-c(extraInfo, fwdPrimerSeq, revPrimerSeq)) %>%
        rename(genePair = genePairsName,
               ahringer384 = sourceBioscienceLocation) %>%
        mutate(historical = paste0("JA:", genePair),
               plate = gsub("^S([0-9]{1})-", "S0\\1-", plate),
               ahringer96 = paste(str_pad(plate, 3, pad = "0"), well, sep = "-"),
               ahringer96 = gsub("^.*NA.*$", NA, ahringer96),
               ahringer384 = gsub("-([0-9}+)([A-Z]{1})", "-\\1-\\2", ahringer384),
               ahringer384 = gsub("-([0-9]{1})-", "-00\\1-", ahringer384),
               ahringer384 = gsub("-([0-9]{2})-", "-0\\1-", ahringer384)) %>%
        select(-c(plate, well, chrom))
    name <- paste0("chr", chromosomes[i])
    list[[i]] <- tbl
}
ahringer <- bind_rows(list)
rm(chromosomes, i, list, name, tbl)

# ORFeome ====
if (!file.exists("data-raw/orfeome.xlsx")) {
    download.file("http://dharmacon.gelifesciences.com/uploadedFiles/Resources/cernai-feeding-library.xlsx",
                  "data-raw/orfeome.xlsx")
}
orfeome <- read_excel("data-raw/orfeome.xlsx", sheet = 2) %>%
    set_names(camel(names(.))) %>%
    rename(genePair = orfIdWs112) %>%
    select(plate, row, col, genePair) %>%
    filter(!grepl("no match", genePair)) %>%
    filter(!is.na(genePair)) %>%
    mutate(historical = paste0("MV_SV:mv_", genePair),
           orfeome96 = paste0(plate, "-", row, str_pad(col, 2, pad = "0"))) %>%
    select(-c(plate, row, col))

# Bind ====
bind <- bind_rows(ahringer, orfeome) %>%
    select(genePair, historical, orfeome96, ahringer96, ahringer384) %>%
    mutate(genePair = gsub("(\\.[0-9]+)[a-z]{1}$", "\\1", genePair)) %>%
    arrange(historical)

load("data-raw/wbrnai.rda")
if (!exists("wbrnai")) {
    wbrnai <- historical2wbrnai(bind$historical)
}

load("data-raw/sequence.rda")
if (!exists("sequence")) {
    sequence1 <- wormbaseRestRnaiSequence(wbrnai$wbrnai[00001:05000])
    sequence2 <- wormbaseRestRnaiSequence(wbrnai$wbrnai[05001:10000])
    sequence3 <- wormbaseRestRnaiSequence(wbrnai$wbrnai[10001:15000])
    sequence4 <- wormbaseRestRnaiSequence(wbrnai$wbrnai[15001:20000])
    sequence5 <- wormbaseRestRnaiSequence(wbrnai$wbrnai[20001:25000])
    sequence6 <- wormbaseRestRnaiSequence(wbrnai$wbrnai[25001:nrow(wbrnai)])
    sequence <- bind_rows(sequence1,
                          sequence,
                          sequence3,
                          sequence4,
                          sequence5,
                          sequence6)
    save(sequence, file = "data-raw/sequence.rda")
}
sequence <- sequence %>% select(-sequence)

load("data-raw/targets.rda")
if (!exists("targets")) {
    targets1 <- wormbaseRestRnaiTargets(wbrnai$wbrnai[00001:05000])
    targets2 <- wormbaseRestRnaiTargets(wbrnai$wbrnai[05001:10000])
    targets3 <- wormbaseRestRnaiTargets(wbrnai$wbrnai[10001:15000])
    targets4 <- wormbaseRestRnaiTargets(wbrnai$wbrnai[15001:20000])
    targets5 <- wormbaseRestRnaiTargets(wbrnai$wbrnai[20001:25000])
    targets6 <- wormbaseRestRnaiTargets(wbrnai$wbrnai[25001:nrow(wbrnai)])
    targets <- bind_rows(tarets1,
                         targets2,
                         targets3,
                         targets4,
                         targets5,
                         targets6)
    save(targets, file = "data-raw/targets.rda")
}

load("data-raw/oligo2geneId.rda")
if (!exists("oligo2geneId")) {
    source("data-raw/oligo2geneId.R")
}

bind <- bind %>%
    left_join(wbrnai, by = "historical") %>%
    left_join(sequence, by = "wbrnai") %>%
    left_join(targets, by = "wbrnai") %>%
    left_join(oligo2geneId, by = "oligo") %>%
    distinct %>%
    arrange(historical)

# Matched by historical2geneId()
matchedHistorical <- bind %>% filter(!is.na(geneId))
unmatched <- bind %>% filter(is.na(geneId)) %>%
    select(-geneId) %>%
    mutate(oligo = historical,
           oligo = gsub("^MV:", "", oligo),
           oligo = gsub("^JA:", "sjj_", oligo))

# Matched by oligo2geneId
matchedOligo <- unmatched %>%
    left_join(oligo2geneId, by = "oligo") %>%
    filter(!is.na(geneId))
unmatched <- unmatched %>% filter(!(oligo %in% matchedOligo$oligo))

# Matched by gene()
matchedGene <- unmatched$genePair %>%
    gene(format = "orf") %>%
    mutate(genePair = orf) %>%
    left_join(unmatched, by = "genePair") %>%
    select(-orf)
unmatched <- unmatched %>% filter(!(genePair %in% matchedGene$genePair))

# Matched by deadOrf()
matchedDeadOrf <- unmatched$genePair %>%
    deadOrf %>%
    left_join(unmatched, by = "genePair")
unmatched <- unmatched %>% filter(!(genePair %in% matchedDeadOrf$genePair))

cloneData <- dplyr::bind_rows(matchedHistorical,
                              matchedOligo,
                              matchedGene,
                              matchedDeadOrf,
                              unmatched) %>%
    arrange(historical)
devtools::use_data(cloneData, overwrite = TRUE)

dupeGeneId <- cloneData %>%
    filter(duplicated(geneId)) %>%
    select(geneId) %>% .[[1]] %>%
    sort %>% unique %>% stats::na.omit(.)
dupeHistorical <- bind %>%
    filter(duplicated(historical)) %>%
    select(historical) %>% .[[1]] %>%
    sort %>% unique %>% stats::na.omit(.)
dupeAhringer96 <- cloneData %>%
    filter(duplicated(ahringer96)) %>%
    select(ahringer96) %>% .[[1]] %>%
    sort %>% unique %>% stats::na.omit(.)
dupeAhringer384 <- cloneData %>%
    filter(duplicated(ahringer384)) %>%
    select(ahringer384) %>% .[[1]] %>%
    sort %>% unique %>% stats::na.omit(.)
dupeOrfeome96 <- cloneData %>%
    filter(duplicated(orfeome96)) %>%
    select(orfeome96) %>% .[[1]] %>%
    sort %>% unique %>% stats::na.omit(.)
head(dupeAhringer96)
head(dupeAhringer384)
head(dupeOrfeome96)
