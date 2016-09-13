library(dplyr)
library(magrittr)
library(readxl)
library(seqcloudr)
load("data-raw/orfeome.rda")

if (!exists("orfeome")) {
    orfeome <- list()
}

if (!file.exists("data-raw/orfeome.xlsx")) {
    download.file("http://dharmacon.gelifesciences.com/uploadedFiles/Resources/cernai-feeding-library.xlsx",
                  "data-raw/orfeome.xlsx")
}

orfeome[["raw"]] <- read_excel("data-raw/orfeome.xlsx", sheet = 2) %>%
    magrittr::set_names(seqcloudr::camel(names(.))) %>%
    rename(genePair = orfIdWs112) %>%
    mutate(genePair = gsub("^no match.*", NA, genePair)) %>%
    filter(!is.na(genePair)) %>%
    select(plate, row, col, genePair) %>%
    mutate(historical = paste0("MV_SV:mv_", genePair),
           orfeome96 = paste0(plate, "-", row, stringr::str_pad(col, 2, pad = "0"))) %>%
    select(-c(plate, row, col))

if (is.null(orfeome$wbrnai)) {
    orfeome[["wbrnai"]] <- historical2wbrnai(historical)
}

if (is.null(orfeome$sequence)) {
    orfeome[["sequence"]] <- wormbaseRestRnaiSequence(orfeome$wbrnai$wbrnai)
}

if (is.null(orfeome$targets)) {
    orfeome[["targets"]] <- wormbaseRestRnaiTargets(orfeome$wbrnai$wbrnai)
}

save(orfeome, file = "data-raw/orfeome.rda")
