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

raw <- dplyr::bind_rows(ahringer, orfeome, cherrypick) %>%
    dplyr::mutate(genePair = gsub("(\\.[0-9]+)[a-z]{1}$", "\\1", genePair))
rm(ahringer, cherrypick, orfeome)


# Historical RNAi Identifiers ====
mv <- raw %>%
    dplyr::filter(!is.na(orfeome96)) %>%
    dplyr::mutate(historical = paste0("MV_SV:mv_", genePair))
ja <- raw %>%
    dplyr::filter(is.na(orfeome96)) %>%
    dplyr::mutate(historical = paste0("JA:", genePair))

# Check that all rows were selected:
nrow(raw)
nrow(mv) + nrow(ja)

unique <- dplyr::bind_rows(mv, ja) %>%
    dplyr::group_by(historical) %>%
    seqcloudr::rowCollapse(.)


# WormBase RESTful queries (CPU intensive) ====
load("data-raw/rnai.rda")
if (!exists("rnai")) {
    rnai <- wormbaseHistorical2rnai(unique$historical)
    save(rnai, file = "data-raw/rnai.rda")
}

load("data-raw/sequence.rda")
if (!exists("sequence")) {
    sequence <- list()
    # Separate requests to server (slower, but more reliable)
    for (i in 1:nrow(rnai)) {
        sequence[[i]] <- wormbaseRestRnaiSequence(rnai$rnai[i])
    }
    sequence <- dplyr::bind_rows(sequence)
    save(sequence, file = "data-raw/sequence.rda")
}

load("data-raw/targets.rda")
if (!exists("targets")) {
    targets <- list()
    for (i in 1:nrow(rnai)) {
        targets[[i]] <- wormbaseRestRnaiTargets(rnai$rnai[i])
    }
    targets <- dplyr::bind_rows(targets)
    save(targets, file = "data-raw/targets.rda")
}


# Annotation joins ===
# WormBase FTP oligo info
load("data-raw/oligo2gene.rda")
if (!exists("oligo2gene")) {
    source("data-raw/oligo2gene.R")
}

master <- unique %>%
    dplyr::left_join(rnai, by = "historical") %>%
    dplyr::left_join(sequence, by = "rnai") %>%
    dplyr::left_join(targets, by = "rnai") %>%
    dplyr::left_join(oligo2gene, by = "oligo") %>%
    dplyr::distinct(.) %>%
    dplyr::arrange(historical)

matched <- list()

# Matched by wormbaseHistorical2rnai()
matched[["historical"]] <- master %>%
    dplyr::filter(!is.na(gene))
print(matched$historical)
unmatched <- master %>%
    dplyr::filter(is.na(gene)) %>%
    dplyr::select(-gene) %>%
    dplyr::mutate(oligo = historical,
                  oligo = gsub("^MV_SV:", "", oligo),
                  oligo = gsub("^JA:", "sjj_", oligo))
print(unmatched)

# Matched by oligo2gene
matched[["oligo"]] <- unmatched %>%
    dplyr::left_join(oligo2gene, by = "oligo") %>%
    dplyr::filter(!is.na(gene))
print(matched$oligo)
unmatched <- unmatched %>%
    dplyr::filter(!(oligo %in% matched[["oligo"]]["oligo"][[1]]))
print(unmatched)

# Matched by gene()
matched[["gene"]] <- unmatched$genePair %>%
    gene(., format = "sequence") %>%
    dplyr::mutate(genePair = sequence) %>%
    dplyr::left_join(unmatched, by = "genePair") %>%
    dplyr::select(-c(name, sequence))
print(matched$gene)
unmatched <- unmatched %>%
    dplyr::filter(!(genePair %in% matched[["gene"]]["genePair"][[1]]))
print(unmatched)

# Matched by wormbaseGeneMerge()
matched[["merge"]] <- wormbaseGeneMerge(unmatched$genePair) %>%
    dplyr::left_join(unmatched, by = "genePair")
print(matched$merge)
unmatched <- unmatched %>%
    dplyr::filter(!(genePair %in% matched[["merge"]]["genePair"][[1]]))
print(unmatched)

rnaiData <- dplyr::bind_rows(matched, unmatched) %>%
    dplyr::select(-genePair) %>%
    dplyr::left_join(gene(.["gene"][[1]], format = "gene"), by = "gene") %>%
    dplyr::group_by(historical) %>%
    seqcloudr::rowCollapse(.) %>%
    dplyr::select(noquote(order(names(.)))) %>%
    dplyr::arrange(historical)
devtools::use_data(rnaiData, overwrite = TRUE)


# Duplicate check ====
dupeGene <- rnaiData %>%
    dplyr::filter(duplicated(gene)) %>%
    dplyr::select(gene) %>%
    .[[1]] %>%
    seqcloudr::sortUnique(.)
dupeHistorical <- rnaiData %>%
    dplyr::filter(duplicated(historical)) %>%
    dplyr::select(historical) %>%
    .[[1]] %>%
    seqcloudr::sortUnique(.)
dupeAhringer96 <- rnaiData %>%
    dplyr::filter(duplicated(ahringer96)) %>%
    dplyr::select(ahringer96) %>%
    .[[1]] %>%
    seqcloudr::sortUnique(.)
dupeAhringer384 <- rnaiData %>%
    dplyr::filter(duplicated(ahringer384)) %>%
    dplyr::select(ahringer384) %>%
    .[[1]] %>%
    seqcloudr::sortUnique(.)
dupeOrfeome96 <- rnaiData %>%
    dplyr::filter(duplicated(orfeome96)) %>%
    dplyr::select(orfeome96) %>%
    .[[1]] %>%
    seqcloudr::sortUnique(.)
head(dupeAhringer96)
head(dupeAhringer384)
head(dupeOrfeome96)
