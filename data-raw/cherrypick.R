library(dplyr)
library(readxl)
library(stringr)
workbook <- "data-raw/cherrypick.xlsx"
sheet <- excel_sheets(workbook)
raw <- list()
for (i in 1:length(sheet)) {
    raw[[i]] <- read_excel(workbook, sheet = sheet[i],
                           col_types = c("numeric", "text", "numeric",
                                         "text", "text", "text", "numeric",
                                         "text")) %>%
        mutate(cherrypick = paste0(sheet[i], "-",
                                   str_pad(plateNum, 2, pad = "0"), "-",
                                   plateRow,
                                   str_pad(plateCol, 2, pad = "0")),
               clone = paste0(sourceLibrary, "-",
                              str_pad(sourcePlateNum, 3, pad = "0"), "-",
                              sourcePlateRow,
                              str_pad(sourcePlateCol, 2, pad = "0")),
               # NA fix
               clone = gsub("^NA", NA, clone),
               # Clone library columns
               ahringer96Historical = str_extract(clone, "^ahringer96-.*$"),
               ahringer96Historical = gsub("^ahringer96-", "", ahringer96Historical),
               orfeome96 = str_extract(clone, "^orfeome96-.*$"),
               orfeome96 = gsub("^orfeome96-", "", orfeome96),
               # genePair fixes
               genePair = str_trim(genePair),
               # Match only the first entry
               genePair = gsub("/.*$", "", genePair),
               # Remove trailing info, e.g. `(dbd)`
               genePair = gsub("\\(.+\\)$", "", genePair)) %>%
        filter(!is.na(genePair)) %>%
        select(cherrypick, genePair, ahringer96Historical, orfeome96) %>%
        arrange(cherrypick)
}
cherrypick <- bind_rows(raw) %>%
    arrange(cherrypick)
save(cherrypick, file = "data-raw/cherrypick.rda")
rm(i, raw, sheet, workbook)
