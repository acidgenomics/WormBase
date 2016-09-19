library(dplyr)
library(magrittr)
library(readxl)
library(seqcloudr)
library(stringr)
devtools::load_all()

load("data-raw/ahringer.rda")
if (!exists("ahringer")) {
    source("data-raw/ahringer.R")
}

load("data-raw/orfeome.rda")
if (!exists("orfeome")) {
    source("data-raw/orfeome.R")
}

load("data-raw/cherrypick.rda")
if (!exists("cherrypick")) {
    source("data-raw/cherrypick.R")
}

bind <- bind_rows(ahringer, orfeome, cherrypick) %>%
    mutate(genePair = gsub("(\\.[0-9]+)[a-z]{1}$", "\\1", genePair))
rm(ahringer, cherrypick, orfeome)

# Historical RNAi Identifiers ====
mv <- bind %>%
    filter(!is.na(orfeome96)) %>%
    mutate(historical = paste0("MV_SV:mv_", genePair))
ja <- bind %>%
    filter(with(., !is.na(ahringer96) |
                    !is.na(ahringer96Historical) |
                    !is.na(ahringer384))) %>%
    mutate(historical = paste0("JA:", genePair))
# Check that all clones matched
bind %>% filter(with(., is.na(orfeome96) &
                         is.na(ahringer96) &
                         is.na(ahringer96Historical) &
                         is.na(ahringer384)))
bind <- bind_rows(mv, ja) %>%
    group_by(historical) %>%
    summarise_each(funs(str_collapse)) %>%
    cruft

# WormBase RESTful queries (CPU intensive) ====
load("data-raw/rnai.rda")
if (!exists("rnai")) {
    rnai <- historical2rnai(bind$historical)
    save(rnai, file = "data-raw/rnai.rda")
}

load("data-raw/sequence.rda")
if (!exists("sequence")) {
    sequence <- list()
    # Separate requests to server (slower but more reliable)
    for (i in 1:nrow(rnai)) {
        sequence[[i]] <- wormbaseRestRnaiSequence(rnai$rnai[i])
    }
    sequence <- bind_rows(sequence)
    save(sequence, file = "data-raw/sequence.rda")
}

load("data-raw/targets.rda")
if (!exists("targets")) {
    targets <- list()
    for (i in 1:nrow(rnai)) {
        targets[[i]] <- wormbaseRestRnaiTargets(rnai$rnai[i])
    }
    targets <- bind_rows(targets)
    save(targets, file = "data-raw/targets.rda")
}

# Annotation joins ===
# WormBase FTP oligo info
load("data-raw/oligo2gene.rda")
if (!exists("oligo2gene")) {
    source("data-raw/oligo2gene.R")
}

#! bind_backup <- bind
bind <- bind %>%
    left_join(rnai, by = "historical") %>%
    left_join(sequence, by = "rnai") %>%
    left_join(targets, by = "rnai") %>%
    left_join(oligo2gene, by = "oligo") %>%
    distinct %>%
    arrange(historical)

# Matched by historical2rnai()
matchedHistorical <- bind %>% filter(!is.na(gene))
unmatched <- bind %>% filter(is.na(gene)) %>%
    select(-gene) %>%
    mutate(oligo = historical,
           oligo = gsub("^MV:", "", oligo),
           oligo = gsub("^JA:", "sjj_", oligo))

# Matched by oligo2gene
matchedOligo <- unmatched %>%
    left_join(oligo2gene, by = "oligo") %>%
    filter(!is.na(gene))
unmatched <- unmatched %>% filter(!(oligo %in% matchedOligo$oligo))

# Matched by gene()
matchedGene <- unmatched$genePair %>%
    gene(format = "sequence") %>%
    mutate(genePair = sequence) %>%
    left_join(unmatched, by = "genePair") %>%
    select(-c(name, sequence))
unmatched <- unmatched %>% filter(!(genePair %in% matchedGene$genePair))

# Matched by deadSequence()
matchedDeadSequence <- unmatched$genePair %>%
    deadSequence %>%
    left_join(unmatched, by = "genePair")
unmatched <- unmatched %>% filter(!(genePair %in% matchedDeadSequence$genePair))

cloneData <- bind_rows(matchedHistorical,
                       matchedOligo,
                       matchedGene,
                       matchedDeadSequence,
                       unmatched) %>%
    arrange(historical)
devtools::use_data(cloneData, overwrite = TRUE)

# Duplicate check ====
dupeGene <- cloneData %>%
    filter(duplicated(gene)) %>%
    select(gene) %>% .[[1]] %>%
    na.omit %>% unique %>% sort
dupeHistorical <- bind %>%
    filter(duplicated(historical)) %>%
    select(historical) %>% .[[1]] %>%
    na.omit %>% unique %>% sort
dupeAhringer96 <- cloneData %>%
    filter(duplicated(ahringer96)) %>%
    select(ahringer96) %>% .[[1]] %>%
    na.omit %>% unique %>% sort
dupeAhringer384 <- cloneData %>%
    filter(duplicated(ahringer384)) %>%
    select(ahringer384) %>% .[[1]] %>%
    na.omit %>% unique %>% sort
dupeOrfeome96 <- cloneData %>%
    filter(duplicated(orfeome96)) %>%
    select(orfeome96) %>% .[[1]] %>%
    na.omit %>% unique %>% sort
head(dupeAhringer96)
head(dupeAhringer384)
head(dupeOrfeome96)
