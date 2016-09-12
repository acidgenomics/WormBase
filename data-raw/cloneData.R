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
    all <- left_join(library$wbrnai, library$sequence) %>%
        left_join(., library$targets) %>%
        left_join(., oligo2geneId) %>%
        left_join(library$raw, .) %>%
        distinct %>%
        rename(primaryTarget = primary,
               secondaryTarget = secondary) %>%
        select(-c(sequence, wormbaseHistorical))
    # Matched by oligo
    matched1 <- filter(all, !is.na(geneId))
    # Matched with gene()
    matched2 <- filter(all, is.na(geneId)) %>%
        select(genePair) %>% .[[1]] %>%
        gene(format = "orf", select = "simple") %>%
        inner_join(select(all, -geneId), ., by = c("genePair" = "orf")) %>%
        select(-publicName)
    # Matched with deadOrf()
    matched3 <- filter(all, !(genePair %in% c(matched1$genePair,
                                              matched2$genePair))) %>%
        select(genePair) %>% .[[1]] %>%
        deadOrf %>%
        inner_join(select(all, -geneId), .)
    # Check that there's no leftovers
    filter(all, (!genePair %in% c(matched1$genePair,
                                  matched2$genePair,
                                  matched3$genePair)))
    cloneData[[i]] <- bind_rows(matched1, matched2, matched3)
}
devtools::use_data(cloneData, overwrite = TRUE)
