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
    summarise_each(funs(str_collapse))
# Missing NA fix
bind[bind == ""] <- NA

# WormBase RESTful queries (CPU intensive) ====
load("data-raw/wbrnai.rda")
if (!exists("wbrnai")) {
    wbrnai <- historical2wbrnai(bind$historical)
    save(wbrnai, file = "data-raw/wbrnai.rda")
}

load("data-raw/sequence.rda")
if (!exists("sequence")) {
    sequence <- list()
    # Separate requests to server (slower but more reliable)
    for (i in 1:nrow(wbrnai)) {
        sequence[[i]] <- wormbaseRestRnaiSequence(wbrnai$wbrnai[i])
    }
    sequence <- bind_rows(sequence)
    save(sequence, file = "data-raw/sequence.rda")
}

load("data-raw/targets.rda")
if (!exists("targets")) {
    targets <- list()
    for (i in 1:nrow(wbrnai)) {
        targets[[i]] <- wormbaseRestRnaiTargets(wbrnai$wbrnai[i])
    }
    targets <- bind_rows(targets)
    save(targets, file = "data-raw/targets.rda")
}

# Annotation joins ===
# WormBase FTP oligo info
load("data-raw/oligo2geneId.rda")
if (!exists("oligo2geneId")) {
    source("data-raw/oligo2geneId.R")
}

bind_backup <- bind
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

cloneData <- bind_rows(matchedHistorical,
                       matchedOligo,
                       matchedGene,
                       matchedDeadOrf,
                       unmatched) %>%
    arrange(historical)
devtools::use_data(cloneData, overwrite = TRUE)

# Duplicate check ====
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
