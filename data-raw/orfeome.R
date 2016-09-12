orfeome <- list()
if (!file.exists("data-raw/orfeome.xlsx")) {
    download.file("http://dharmacon.gelifesciences.com/uploadedFiles/Resources/cernai-feeding-library.xlsx",
                  "data-raw/orfeome.xlsx")
}
orfeome[["raw"]] <- read_excel("data-raw/orfeome.xlsx", sheet = 2) %>%
    set_names(seqcloudr::camel(names(.))) %>%
    rename(orfeome96Historical = rnaiWell,
           genePair = orfIdWs112) %>%
    mutate(genePair = gsub("^no match.*", NA, genePair)) %>%
    filter(!is.na(genePair)) %>%
    select(genePair, plate, row, col) %>%
    mutate(wormbaseHistorical = paste0("MV_SV:mv_", genePair)) %>%
    mutate(orfeome96 = paste0(plate, "-", row, stringr::str_pad(col, 2, pad = "0"))) %>%
    select(-c(plate, row, col))
if (is.null(orfeome$wbrnai)) {
    orfeome[["wbrnai"]] <- historical2wbrnai(orfeome$raw$wormbaseHistorical)
}
if (is.null(orfeome$sequence)) {
    orfeome[["sequence"]] <- wormbaseRestRnaiSequence(orfeome$wbrnai$wbrnai)
}
if (is.null(orfeome$targets)) {
    orfeome[["targets"]] <- wormbaseRestRnaiTargets(orfeome$wbrnai$wbrnai)
}
save(orfeome, file = "data-raw/orfeome.rda")
