library(dplyr)
library(magrittr)
library(readxl)
library(seqcloudr)
library(stringr)
if (!file.exists("data-raw/orfeome.xlsx")) {
    download.file("http://dharmacon.gelifesciences.com/uploadedFiles/Resources/cernai-feeding-library.xlsx",
                  "data-raw/orfeome.xlsx")
}
orfeome <- read_excel("data-raw/orfeome.xlsx", sheet = 2) %>%
    set_names(camel(names(.))) %>%
    rename(genePair = orfIdWs112) %>%
    select(plate, row, col, genePair) %>%
    filter(!grepl("no match", genePair)) %>%
    filter(!is.na(genePair)) %>%
    mutate(orfeome96 = paste0(plate, "-", row, str_pad(col, 2, pad = "0"))) %>%
    select(-c(plate, row, col))
save(orfeome, file = "data-raw/orfeome.rda")
