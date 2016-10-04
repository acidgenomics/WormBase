library(dplyr)
library(readxl)
library(seqcloudr)
library(stringr)

fileLocal <- "data-raw/orfeome.xlsx"
if (!file.exists(fileLocal)) {
    utils::download.file("http://dharmacon.gelifesciences.com/uploadedFiles/Resources/cernai-feeding-library.xlsx",
                         fileLocal)
}
orfeome <- readxl::read_excel(fileLocal, sheet = 2) %>%
    stats::setNames(., seqcloudr::camel(names(.))) %>%
    dplyr::rename(genePair = orfIdWs112) %>%
    dplyr::select(plate, row, col, genePair) %>%
    dplyr::filter(!grepl("no match", genePair)) %>%
    dplyr::filter(!is.na(genePair)) %>%
    dplyr::mutate(orfeome96 = paste0(plate, row, col)) %>%
    dplyr::select(-c(plate, row, col))
devtools::use_data(orfeome, overwrite = TRUE)
