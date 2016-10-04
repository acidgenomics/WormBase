source("R/wormbaseRest.R")

library(dplyr)
library(magrittr)
library(readxl)
library(seqcloudr)
library(stringr)
library(worminfo)

data(ahringer)
if (!exists("ahringer")) {
    source("data-raw/ahringer.R")
}

data(cherrypick)
if (!exists("cherrypick")) {
    source("data-raw/cherrypick.R")
}

data(orfeome)
if (!exists("orfeome")) {
    source("data-raw/orfeome.R")
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
data(wormbaseRnaiIdentifier)
if (!exists("wormbaseRnaiIdentifier")) {
    wormbaseRnaiIdentifier <- wormbaseRestHistoricalToRnai(unique$historical)
    devtools::use_data(wormbaseRnaiIdentifier, overwrite = TRUE)
}

data(wormbaseRnaiSequence)
if (!exists("wormbaseRestRnaiSequence")) {
    sequence <- list()
    # Separate requests to server (slower, but more reliable)
    for (i in 1:nrow(wormbaseRestRnaiIdentifier)) {
        sequence[[i]] <- wormbaseRestRnaiSequence(wormbaseRnaiIdentifier$rnai[i])
    }
    wormbaseRnaiSequence <- dplyr::bind_rows(sequence)
    devtools::use_data(wormbaseRnaiSequence, overwrite = TRUE)
}

data(wormbaseRnaiTargets)
if (!exists("wormbaseRnaiTargets")) {
    targets <- list()
    for (i in 1:nrow(rnai)) {
        targets[[i]] <- wormbaseRestRnaiTargets(wormbaseRnaiIdentifier$rnai[i])
    }
    wormbaseRnaiTargets <- dplyr::bind_rows(targets)
    devtools::use_data(wormbaseRnaiTargets, overwrite = TRUE)
}


# Annotation joins ===
data(wormbaseFtpOligo)
if (!exists("wormbaseFtpOligo")) {
    source("data-raw/wormbaseFtp.R")
}

master <- unique %>%
    dplyr::left_join(wormbaseRnaiIdentifier, by = "historical") %>%
    dplyr::left_join(wormbaseRnaiSequence, by = "rnai") %>%
    dplyr::left_join(wormbaseRnaiTargets, by = "rnai") %>%
    dplyr::left_join(wormbaseFtpOligo, by = "oligo") %>%
    dplyr::distinct(.) %>%
    dplyr::arrange(historical)

matched <- list()

# Matched by wormbaseHistoricalToRnai()
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

# Matched by oligo
matched[["oligo"]] <- unmatched %>%
    dplyr::left_join(wormbaseFtpOligo, by = "oligo") %>%
    dplyr::filter(!is.na(gene))
print(matched$oligo)
unmatched <- unmatched %>%
    dplyr::filter(!(oligo %in% matched[["oligo"]]["oligo"][[1]]))
print(unmatched)

# Matched by worminfo::gene()
matched[["gene"]] <-
    worminfo::gene(unmatched$genePair, format = "sequence", select = "gene") %>%
    dplyr::rename(genePair = sequence) %>%
    dplyr::left_join(unmatched, by = "genePair") %>%
    print(matched$gene)
unmatched <- unmatched %>%
    dplyr::filter(!(genePair %in% matched[["gene"]]["genePair"][[1]]))
print(unmatched)

# Matched by wormbaseRestGeneMerge()
matched[["merge"]] <- wormbaseRestGeneMerge(unmatched$genePair) %>%
    dplyr::left_join(unmatched, by = "genePair")
print(matched$merge)
unmatched <- unmatched %>%
    dplyr::filter(!(genePair %in% matched[["merge"]]["genePair"][[1]]))
print(unmatched)

rnaiSource <- dplyr::bind_rows(matched, unmatched) %>%
    dplyr::select(-genePair) %>%
    dplyr::left_join(worminfo::gene(.["gene"][[1]],
                                    format = "gene",
                                    select = c("name", "sequence")),
                     by = "gene") %>%
    dplyr::group_by(historical) %>%
    seqcloudr::rowCollapse(.) %>%
    dplyr::select(noquote(order(names(.)))) %>%
    dplyr::arrange(historical)
devtools::use_data(rnaiSource, overwrite = TRUE)


# Duplicate check ====
dupeGene <- rnaiSource %>%
    dplyr::filter(duplicated(gene)) %>%
    dplyr::select(gene) %>%
    .[[1]] %>%
    seqcloudr::sortUnique(.)
dupeHistorical <- rnaiSource %>%
    dplyr::filter(duplicated(historical)) %>%
    dplyr::select(historical) %>%
    .[[1]] %>%
    seqcloudr::sortUnique(.)
dupeAhringer96 <- rnaiSource %>%
    dplyr::filter(duplicated(ahringer96)) %>%
    dplyr::select(ahringer96) %>%
    .[[1]] %>%
    seqcloudr::sortUnique(.)
dupeAhringer384 <- rnaiSource %>%
    dplyr::filter(duplicated(ahringer384)) %>%
    dplyr::select(ahringer384) %>%
    .[[1]] %>%
    seqcloudr::sortUnique(.)
dupeOrfeome96 <- rnaiSource %>%
    dplyr::filter(duplicated(orfeome96)) %>%
    dplyr::select(orfeome96) %>%
    .[[1]] %>%
    seqcloudr::sortUnique(.)
head(dupeAhringer96)
head(dupeAhringer384)
head(dupeOrfeome96)
