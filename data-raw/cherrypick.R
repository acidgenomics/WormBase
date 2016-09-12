library(dplyr)
library(readxl)
library(worminfo)
workbook <- "data-raw/cherrypick.xlsx"
sheet <- readxl::excel_sheets(workbook)
raw <- list()
for (i in 1:length(sheet)) {
    raw[[i]] <- readxl::read_excel(workbook, sheet = sheet[i], col_types = rep("text", 12)) %>%
        select(plateId, cloneId, genePair)
}
raw <- bind_rows(raw) %>%
    arrange(plateId)
orfeome <- filter(raw, grepl("^orfeome", cloneId))
if (nrow(orfeome)) {
    orfeome <- worminfo::clone(orfeome$cloneId, library = "orfeome") %>%
        mutate(cloneId = paste0("orfeome96-", orfeome96)) %>%
        left_join(orfeome, ., by = "cloneId")
}
ahringer <- filter(raw, grepl("^ahringer", cloneId))
if (nrow(ahringer)) {
    ahringer <- worminfo::clone(raw$cloneId, library = "ahringer", wells = 96) %>%
        mutate(cloneId = paste0("ahringer96-", ahringer96)) %>%
        left_join(ahringer, ., by = "cloneId")
}
cherrypick <- bind_rows(orfeome, ahringer) %>%
    arrange(plateId)

mismatch <- filter(cherrypick, genePair.x != genePair.y)
missing <- filter(cherrypick, is.na(genePair.y))
