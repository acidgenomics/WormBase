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

bind <- dplyr::bind_rows(ahringer, orfeome, cherrypick) %>%
    dplyr::mutate(genePair = gsub("(\\.[0-9]+)[a-z]{1}$", "\\1", genePair))
rm(ahringer, cherrypick, orfeome)

# Historical RNAi Identifiers ====
mv <- bind %>%
    dplyr::filter(!is.na(orfeome96)) %>%
    dplyr::mutate(historical = paste0("MV_SV:mv_", genePair))
ja <- bind %>%
    dplyr::filter(with(!is.na(ahringer96) |
                              !is.na(ahringer96Historical) |
                              !is.na(ahringer384))) %>%
    dplyr::mutate(historical = paste0("JA:", genePair))

# Check that all clones matched
bind %>% dplyr::filter(with(is.na(orfeome96) &
                                   is.na(ahringer96) &
                                   is.na(ahringer96Historical) &
                                   is.na(ahringer384)))

bind <- dplyr::bind_rows(mv, ja) %>%
    dplyr::group_by(historical) %>%
    # seqcloudr::str_collapse
    dplyr::summarise_each(funs(str_collapse)) %>%
    seqcloudr::cruft(.)

# WormBase RESTful queries (CPU intensive) ====
load("data-raw/rnai.rda")
if (!exists("rnai")) {
    rnai <- worminfo::historical2rnai(bind$historical)
    save(rnai, file = "data-raw/rnai.rda")
}

load("data-raw/sequence.rda")
if (!exists("sequence")) {
    sequence <- list()
    # Separate requests to server (slower but more reliable)
    for (i in 1:nrow(rnai)) {
        sequence[[i]] <- worminfo::wormbaseRestRnaiSequence(rnai$rnai[i])
    }
    sequence <- dplyr::bind_rows(sequence)
    save(sequence, file = "data-raw/sequence.rda")
}

load("data-raw/targets.rda")
if (!exists("targets")) {
    targets <- list()
    for (i in 1:nrow(rnai)) {
        targets[[i]] <- worminfo::wormbaseRestRnaiTargets(rnai$rnai[i])
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

bind_backup <- bind

bind <- bind %>%
    dplyr::left_join(rnai, by = "historical") %>%
    dplyr::left_join(sequence, by = "rnai") %>%
    dplyr::left_join(targets, by = "rnai") %>%
    dplyr::left_join(oligo2gene, by = "oligo") %>%
    dplyr::distinct(.) %>%
    dplyr::arrange(historical)

# Matched by historical2rnai()
matchedHistorical <- bind %>%
    dplyr::filter(!is.na(gene))
unmatched <- bind %>%
    dplyr::filter(is.na(gene)) %>%
    dplyr::select(-gene) %>%
    dplyr::mutate(oligo = historical,
                  oligo = gsub("^MV_SV:", "", oligo),
                  oligo = gsub("^JA:", "sjj_", oligo))

# Matched by oligo2gene
matchedOligo <- unmatched %>%
    dplyr::left_join(oligo2gene, by = "oligo") %>%
    dplyr::filter(!is.na(gene))
unmatched <- unmatched %>%
    dplyr::filter(!(oligo %in% matchedOligo$oligo))

# Matched by gene()
matchedGene <- unmatched$genePair %>%
    worminfo::gene(format = "sequence") %>%
    dplyr::mutate(genePair = sequence) %>%
    dplyr::left_join(unmatched, by = "genePair") %>%
    dplyr::select(-c(name, sequence))
unmatched <- unmatched %>%
    dplyr::filter(!(genePair %in% matchedGene$genePair))

# Matched by deadSequence()
matchedDeadSequence <- unmatched$genePair %>%
    worminfo::deadSequence(.) %>%
    dplyr::left_join(unmatched, by = "genePair")
unmatched <- unmatched %>%
    dplyr::filter(!(genePair %in% matchedDeadSequence$genePair))

cloneData <- dplyr::bind_rows(matchedHistorical,
                              matchedOligo,
                              matchedGene,
                              matchedDeadSequence,
                              unmatched)
cloneData <- dplyr::left_join(cloneData,
                              worminfo::gene(cloneData$gene, format = "gene"),
                              by = "gene") %>%
    seqcloudr::cruft(.) %>%
    dplyr::select(noquote(order(names(.)))) %>%
    dplyr::arrange(historical)
devtools::use_data(cloneData, overwrite = TRUE)


# Duplicate check ====
dupeGene <- cloneData %>%
    dplyr::filter(duplicated(gene)) %>%
    dplyr::select(gene) %>%
    .[[1]] %>%
    stats::na.omit(.) %>%
    unique(.) %>%
    sort(.)
dupeHistorical <- bind %>%
    dplyr::filter(duplicated(historical)) %>%
    dplyr::select(historical) %>%
    .[[1]] %>%
    stats::na.omit(.) %>%
    unique %>%
    sort
dupeAhringer96 <- cloneData %>%
    dplyr::filter(duplicated(ahringer96)) %>%
    dplyr::select(ahringer96) %>%
    .[[1]] %>%
    stats::na.omit(.) %>%
    unique(.) %>%
    sort(.)
dupeAhringer384 <- cloneData %>%
    dplyr::filter(duplicated(ahringer384)) %>%
    dplyr::select(ahringer384) %>%
    .[[1]] %>%
    stats::na.omit(.) %>%
    unique %>%
    sort
dupeOrfeome96 <- cloneData %>%
    dplyr::filter(duplicated(orfeome96)) %>%
    dplyr::select(orfeome96) %>%
    .[[1]] %>%
    stats::na.omit(.) %>%
    unique(.) %>%
    sort(.)
head(dupeAhringer96)
head(dupeAhringer384)
head(dupeOrfeome96)
