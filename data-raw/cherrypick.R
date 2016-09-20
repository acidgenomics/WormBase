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
        dplyr::mutate(cherrypick = paste0(sheet[i], "-",
                                          stringr::str_pad(plateNum, 2, pad = "0"), "-",
                                          plateRow,
                                          stringr::str_pad(plateCol, 2, pad = "0")),
                      clone = paste0(sourceLibrary, "-",
                                     stringr::str_pad(sourcePlateNum, 3, pad = "0"), "-",
                                     sourcePlateRow,
                                     stringr::str_pad(sourcePlateCol, 2, pad = "0")),
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
        dplyr::select(cherrypick, genePair, ahringer96Historical, orfeome96) %>%
        dplyr::arrange(cherrypick)
}
cherrypick <- dplyr::bind_rows(raw) %>%
    dplyr::arrange(cherrypick)
save(cherrypick, file = "data-raw/cherrypick.rda")
rm(i, raw, sheet, workbook)
