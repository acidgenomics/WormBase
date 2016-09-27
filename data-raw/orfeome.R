library(dplyr)
library(readxl)
library(seqcloudr)
library(stringr)
if (!file.exists("data-raw/orfeome.xlsx")) {
    utils::download.file("http://dharmacon.gelifesciences.com/uploadedFiles/Resources/cernai-feeding-library.xlsx",
                         "data-raw/orfeome.xlsx")
}
orfeome <- readxl::read_excel("data-raw/orfeome.xlsx", sheet = 2) %>%
    stats::setNames(., seqcloudr::camel(names(.))) %>%
    dplyr::rename(genePair = orfIdWs112) %>%
    dplyr::select(plate, row, col, genePair) %>%
    dplyr::filter(!grepl("no match", genePair)) %>%
    dplyr::filter(!is.na(genePair)) %>%
    dplyr::mutate(orfeome96 = paste0(plate, row, col)) %>%
    dplyr::select(-c(plate, row, col))
save(orfeome, file = "data-raw/orfeome.rda")
