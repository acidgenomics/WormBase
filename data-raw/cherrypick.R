library(dplyr)
library(readxl)
library(stringr)
workbook <- "data-raw/cherrypick.xlsx"
sheet <- readxl::excel_sheets(workbook)
raw <- list()
for (i in 1:length(sheet)) {
    raw[[i]] <- readxl::read_excel(workbook, sheet = sheet[i],
                                   col_types = c("numeric", "text", "numeric",
                                                 "text", "text", "text", "numeric",
                                                 "text")) %>%
        dplyr::mutate(cherrypick = paste0(sheet[i],
                                          plateNum,
                                          plateRow,
                                          plateCol),
                      clone = paste0(sourceLibrary,
                                     "-",
                                     sourcePlateNum,
                                     sourcePlateRow,
                                     sourcePlateCol),
                      # NA fix
                      clone = gsub("^NA", NA, clone),
                      # Clone library columns
                      ahringer96Historical = stringr::str_extract(clone, "^ahringer96-.*$"),
                      ahringer96Historical = gsub("^ahringer96-", "", ahringer96Historical),
                      orfeome96 = stringr::str_extract(clone, "^orfeome96-.*$"),
                      orfeome96 = gsub("^orfeome96-", "", orfeome96),
                      # genePair fixes
                      genePair = stringr::str_trim(genePair),
                      # Match only the first entry
                      genePair = gsub("/.*$", "", genePair),
                      # Remove trailing info, e.g. `(dbd)`
                      genePair = gsub("\\(.+\\)$", "", genePair)) %>%
        dplyr::filter(!is.na(genePair)) %>%
        dplyr::select(cherrypick, genePair, ahringer96Historical, orfeome96)
}
cherrypick <- dplyr::bind_rows(raw) %>%
    dplyr::arrange(genePair, cherrypick)
save(cherrypick, file = "data-raw/cherrypick.rda")
rm(i, raw, sheet, workbook)
