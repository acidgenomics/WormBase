library(dplyr)
library(magrittr)
library(readxl)
library(seqcloudr)
library(tibble)
devtools::load_all()

# Ahringer ====
data(ahringer)
if (!exists("ahringer")) {
    ahringer <- list()
    if (!file.exists("data-raw/ahringer.xlsx")) {
        download.file("http://www.us.lifesciences.sourcebioscience.com/media/381254/C.%20elegans%20Database%202012.xlsx",
                      "data-raw/ahringer.xlsx")
    }
    chromosomes <- c("I", "II", "III", "IV", "V", "X")
    list <- list()
    for (i in 1:length(chromosomes)) {
        tbl <- read_excel("data-raw/ahringer.xlsx", sheet = i + 1) %>% # First sheet contains notes
            set_names(camel(names(.))) %>%
            select(-extraInfo) %>%
            rename(genePair = genePairsName, sourceBioscience384 = sourceBioscienceLocation) %>%
            mutate(wormbaseHistorical = paste0("JA:", genePair)) %>%
            mutate(fwdPrimerSeq = tolower(fwdPrimerSeq), revPrimerSeq = tolower(revPrimerSeq)) %>%
            mutate(ahringer96 = do.call(paste, c(.[, c("chrom", "plate", "well")], sep = "-"))) %>%
            mutate(ahringer96 = gsub("-([A-Z]{1}[0-9]{2})$", "\\1", ahringer96)) %>%
            select(-c(plate, well, chrom))
        name <- paste0("chr", chromosomes[i])
        list[[i]] <- tbl
    }
    ahringer[["raw"]] <- dplyr::bind_rows(list)
    rm(chromosomes, i, list, name, tbl)
    if (is.null(ahringer$wbrnai)) {
        ahringer[["wbrnai"]] <- historical2wbrnai(ahringer$raw$wormbaseHistorical)
    }
    if (is.null(ahringer$sequence)) {
        rest1 <- wormbaseRestRnaiSequence(ahringer$wbrnai$wbrnai[00001:05000])
        rest2 <- wormbaseRestRnaiSequence(ahringer$wbrnai$wbrnai[05001:10000])
        rest3 <- wormbaseRestRnaiSequence(ahringer$wbrnai$wbrnai[10001:15000])
        rest4 <- wormbaseRestRnaiSequence(ahringer$wbrnai$wbrnai[15001:nrow(ahringer$wbrnai)])
        ahringer$sequence <- bind_rows(rest1, rest2, rest3, rest4)
        rm(rest1, rest2, rest3, rest4)
    }
    if (is.null(ahringer$targets)) {
        rest1 <- wormbaseRestRnaiTargets(ahringer$wbrnai$wbrnai[00001:05000])
        rest2 <- wormbaseRestRnaiTargets(ahringer$wbrnai$wbrnai[05001:10000])
        rest3 <- wormbaseRestRnaiTargets(ahringer$wbrnai$wbrnai[10001:15000])
        rest4 <- wormbaseRestRnaiTargets(ahringer$wbrnai$wbrnai[15001:nrow(ahringerWbrnai)])
        ahringer$targets <- bind_rows(rest1, rest2, rest3, rest4)
        rm(rest1, rest2, rest3, rest4)
    }
    devtools::use_data(ahringer, overwrite = TRUE)
}

# Orfeome ====
data(orfeome)
if (!exists("orfeome")) {
    orfeome <- list()
    if (!file.exists("data-raw/orfeome.xlsx")) {
        download.file("http://dharmacon.gelifesciences.com/uploadedFiles/Resources/cernai-feeding-library.xlsx",
                      "data-raw/orfeome.xlsx")
    }
    orfeome[["raw"]] <- read_excel("data-raw/orfeome.xlsx", sheet = 2) %>%
        set_names(camel(names(.))) %>%
        rename(orfeome96Historical = rnaiWell,
               genePair = orfIdWs112) %>%
        mutate(genePair = gsub("^no match.*", NA, genePair)) %>%
        filter(!is.na(genePair)) %>%
        select(genePair, plate, row, col, orfeome96Historical) %>%
        mutate(wormbaseHistorical = paste0("MV_SV:mv_", genePair)) %>%
        mutate(orfeome96 = paste(plate, row, col, sep = "-")) %>%
        select(-c(plate, row, col)) %>%
        mutate(orfeome96 = gsub("^(.*)-([0-9]{1})$", "\\1-0\\2", orfeome96)) %>% # pad zeros
        mutate(orfeome96 = gsub("^([0-9]{5})-([A-Z]{1})-([0-9]{2})$", "\\1@\\2\\3", orfeome96))
    if (is.null(orfeome$wbrnai)) {
        orfeome[["wbrnai"]] <- historical2wbrnai(orfeome$raw$wormbaseHistorical)
    }
    if (is.null(orfeome$sequence)) {
        orfeome[["sequence"]] <- wormbaseRestRnaiSequence(orfeome$wbrnai$wbrnai)
    }
    if (is.null(orfeome$targets)) {
        orfeome[["targets"]] <- wormbaseRestRnaiTargets(orfeome$wbrnai$wbrnai)
    }
    devtools::use_data(orfeome, overwrite = TRUE)
}

data(oligo2geneId)
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
    matched1 <- filter(all, !is.na(geneId)) %>%
        mutate(matchedBy = "oligo")
    # Matched with gene()
    matched2 <- filter(all, is.na(geneId)) %>%
        select(genePair) %>% .[[1]] %>%
        gene(format = "orf", output = "simple") %>%
        inner_join(select(all, -geneId), ., by = c("genePair" = "orf")) %>%
        select(-publicName) %>%
        mutate(matchedBy = "gene()")
    # Matched with deadOrf()
    matched3 <- filter(all, !(genePair %in% c(matched1$genePair,
                                              matched2$genePair))) %>%
        select(genePair) %>% .[[1]] %>%
        deadOrf %>%
        inner_join(select(all, -geneId), .) %>%
        mutate(matchedBy = "deadOrf()")
    # Check that there's no leftovers
    filter(all, (!genePair %in% c(matched1$genePair,
                                  matched2$genePair,
                                  matched3$genePair)))
    cloneData[[i]] <- bind_rows(matched1, matched2, matched3)
}
devtools::use_data(cloneData, overwrite = TRUE)
