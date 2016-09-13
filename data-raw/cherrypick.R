library(dplyr)
library(readxl)
library(stringr)
library(worminfo)
workbook <- "data-raw/cherrypick.xlsx"
sheet <- readxl::excel_sheets(workbook)
raw <- list()
for (i in 1:length(sheet)) {
    raw[[i]] <- readxl::read_excel(workbook, sheet = sheet[i],
                                   col_types = c("numeric", "text", "numeric",
                                                 "text", "text", "text", "numeric",
                                                 "text")) %>%
        mutate(plateId = paste0("cherrypick-",
                                sheet[i], "-",
                                str_pad(plateNum, 2, pad = "0"), "-",
                                plateRow,
                                str_pad(plateCol, 2, pad = "0")),
               cloneId = paste0(sourceLibrary, "-",
                                str_pad(sourcePlateNum, 3, pad = "0"), "-",
                                sourcePlateRow,
                                str_pad(sourcePlateCol, 2, pad = "0")),
               # NA fix
               cloneId = gsub("^NA", NA, cloneId),
               # genePair fixes
               genePair = str_trim(genePair),
               # Match only the first entry
               genePair = gsub("/.*$", "", genePair),
               # Remove trailing info, e.g. `(dbd)`
               genePair = gsub("\\(.+\\)$", "", genePair)) %>%
        filter(!is.na(genePair)) %>%
        select(plateId, cloneId, genePair) %>%
        arrange(plateId)
}
raw <- bind_rows(raw) %>% arrange(plateId)

load("data-raw/oligo2geneId.rda")
if (!exists("oligo2geneId")) {
    source("data-raw/oligo2geneId.R")
}

orfeome <- raw %>% filter(grepl("^orfeome", cloneId))
if (nrow(orfeome)) {
    orfeome <- worminfo::clone(orfeome$cloneId, format = "cloneId", library = "orfeome") %>%
        mutate(cloneId = paste0("orfeome96-", orfeome96)) %>%
        left_join(orfeome, .)
    unmatched <- orfeome %>% filter(is.na(geneId)) %>%
        select(plateId, cloneId, genePair)
    # Matched by clone()
    matched1 <- orfeome %>% filter(!is.na(geneId))
    # Matched by gene()
    matched2 <- worminfo::gene(unmatched$genePair, format = "orf") %>%
        mutate(genePair = orf) %>%
        left_join(unmatched, by = "genePair")
    unmatched <- unmatched %>% filter(!(genePair %in% matched2$genePair))
    # Check for unmatched clones
    print(unmatched)
    orfeome <- bind_rows(matched1, matched2) %>%
        arrange(plateId)
    rm(matched1, matched2, unmatched)
}

ahringer <- raw %>% filter(grepl("^ahringer", cloneId))
if (nrow(ahringer)) {
    ahringer <- worminfo::clone(ahringer$genePair, format = "genePair", library = "ahringer") %>%
        left_join(ahringer, .) %>%
        distinct
    unmatched <- ahringer %>% filter(is.na(geneId)) %>%
        select(plateId, cloneId, genePair) %>%
        # Strip isoform from genePair
        mutate(genePair = gsub("\\.([0-9]+)([a-z]{1})$", ".\\1", genePair))
    # Matched by clone()
    matched1 <- ahringer %>% filter(!is.na(geneId))
    # Matched by gene()
    matched2 <- worminfo::gene(unmatched$genePair, format = "orf") %>%
        mutate(genePair = orf) %>%
        left_join(unmatched, by = "genePair")
    unmatched <- filter(unmatched, !(genePair %in% matched2$genePair))
    # Matched by deadOrf()
    matched3 <- unmatched %>%
        select(genePair) %>% .[[1]] %>%
        deadOrf %>%
        inner_join(unmatched, by = "genePair")
    unmatched <- filter(unmatched, !(genePair %in% matched3$genePair))
    # Check for unmatched clones
    print(unmatched)
    ahringer <- bind_rows(matched1, matched2) %>%
        arrange(plateId)
    rm(matched1, matched2, unmatched)

    # Fix missing wbrnai
    wbrnai <- ahringer %>% filter(is.na(wbrnai)) %>%
        select(-wbrnai) %>%
        mutate(historical = paste0("JA:", genePair))
    ahringer <- ahringer %>% filter(!is.na(wbrnai))
    historical <- historical2wbrnai(wbrnai$historical)
    wbrnai <- wbrnai %>% left_join(historical) %>%
        select(-historical)
    ahringer <- bind_rows(ahringer, wbrnai)
}

cherrypick <- bind_rows(ahringer, orfeome) %>%
    arrange(plateId) %>%
    select(plateId,
           cloneId,
           genePair,
           geneId,
           oligo,
           wbrnai)
devtools::use_data(cherrypick, overwrite = TRUE)
