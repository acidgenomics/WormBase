library(dplyr)
library(magrittr)
library(readxl)
library(seqcloudr)
library(stringr)
library(tibble)
devtools::load_all()

load("data-raw/ahringer.rda")
if (!exists("ahringer")) {
    source("data-raw/ahringer.R")
}

load("data-raw/orfeome.rda")
if (!exists("orfeome")) {
    source("data-raw/orfeome.R")
}

load("data-raw/oligo2geneId.rda")
if (!exists("oligo2geneId")) {
    source("data-raw/oligo2geneId.R")
}

libraries <- c("ahringer", "orfeome")
cloneData <- list()
for (i in libraries) {
    library <- get(i)
    all <- left_join(library$wbrnai, library$sequence, by = "wbrnai") %>%
        left_join(., library$targets, by = "wbrnai") %>%
        left_join(., oligo2geneId, by = "oligo") %>%
        left_join(library$raw, ., by = "wormbaseHistorical") %>%
        distinct %>%
        rename(primaryTarget = primary,
               secondaryTarget = secondary) %>%
        select(-c(sequence, wormbaseHistorical))
    unmatched <- filter(all, is.na(geneId))
    # Matched by oligo
    matched1 <- filter(all, !is.na(geneId))
    # Matched by gene()
    matched2 <- unmatched %>%
        select(genePair) %>% .[[1]] %>%
        gene(format = "orf", select = "simple") %>%
        inner_join(select(all, -geneId), ., by = c("genePair" = "orf")) %>%
        select(-publicName)
    unmatched <- filter(unmatched, !(genePair %in% matched2$genePair))
    # Matched by deadOrf()
    matched3 <- unmatched %>%
        select(genePair) %>% .[[1]] %>%
        deadOrf %>%
        inner_join(select(all, -geneId), ., by = "genePair")
    unmatched <- filter(unmatched, !(genePair %in% matched3$genePair))
    # Check that there's no leftovers
    print(unmatched)
    cloneData[[i]] <- bind_rows(matched1, matched2, matched3)
}
devtools::use_data(cloneData, overwrite = TRUE)
