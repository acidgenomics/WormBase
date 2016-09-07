library(dplyr)
library(magrittr)
library(readxl)
library(seqcloudr)
devtools::load_all()

if (!file.exists("data-raw/orfeome.xlsx")) {
    download.file("http://dharmacon.gelifesciences.com/uploadedFiles/Resources/cernai-feeding-library.xlsx",
                  "data-raw/orfeome.xlsx")
}

raw <- read_excel("data-raw/orfeome.xlsx", sheet = 2) %>%
    set_names(camel(names(.))) %>%
    rename(orfeome96Historical = rnaiWell,
           genePair = orfIdWs112) %>%
    mutate(genePair = gsub("^no match.*", NA, genePair)) %>%
    filter(!is.na(genePair)) %>%
    select(genePair, plate, row, col, orfeome96Historical)
# Set plate IDs as rownames
raw$orfeome96 <- do.call(paste, c(raw[, c("plate", "row", "col")], sep = "-")) %>%
    gsub("^(.*)-([0-9]{1})$", "\\1-0\\2", .) %>% # pad zeros
    gsub("^([0-9]{5})-([A-Z]{1})-([0-9]{2})$", "\\1@\\2\\3", .)
raw <- select(raw, -c(plate, row, col))
raw$wormbaseHistorical <- paste0("MV_SV:mv_", raw$genePair)

data(orfeomeWbrnai)
if (!exists("orfeomeWbrnai")) {
    orfeomeWbrnai <- historical2wbrnai(raw$wormbaseHistorical)
    devtools::use_data(orfeomeWbrnai, overwrite = TRUE)
}

data(orfeomeSequence)
if (!exists("orfeomeSequence")) {
    orfeomeSequence <- wormbaseRestRnaiSequence(orfeomeWbrnai$wbrnai)
    devtools::use_data(orfeomeSequence, overwrite = TRUE)
}

data(orfeomeTargets)
if (!exists("orfeomeTargets")) {
    orfeomeTargets <- wormbaseRestRnaiTargets(orfeomeWbrnai$wbrnai)
    devtools::use_data(orfeomeTargets, overwrite = TRUE)
}

orfeome <- list(raw = raw,
                wbrnai = orfeomeWbrnai,
                sequence = orfeomeSequence,
                targets = orfeomeTargets)
devtools::use_data(orfeome, overwrite = TRUE)
