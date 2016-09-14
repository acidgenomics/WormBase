library(dplyr)
library(readxl)
library(stringr)
library(worminfo)
workbook <- "data-raw/cherrypick.xlsx"
sheet <- readxl::excel_sheets(workbook)
raw <- list()
for (i in 1:length(sheet)) {
    raw[[i]] <- readxl::read_excel(workbook, sheet = sheet[i],
                                   col_types = c("numeric", "text", "numeric",
                                                 "text", "text", "text", "numeric",
                                                 "text")) %>%
        mutate(cherrypickId = paste0("cherrypick-",
                                sheet[i], "-",
                                str_pad(plateNum, 2, pad = "0"), "-",
                                plateRow,
                                str_pad(plateCol, 2, pad = "0")),
               cloneId = paste0(sourceLibrary, "-",
                                str_pad(sourcePlateNum, 3, pad = "0"), "-",
                                sourcePlateRow,
                                str_pad(sourcePlateCol, 2, pad = "0")),
               # NA fix
               cloneId = gsub("^NA", NA, cloneId),
               # Clone library columns
               ahringer96 = stringr::str_extract(cloneId, "^ahringer96-.*$"),
               ahringer96 = gsub("^ahringer96-", "", ahringer96),
               orfeome96 = stringr::str_extract(cloneId, "^orfeome96-.*$"),
               orfeome96 = gsub("^orfeome96-", "", orfeome96),
               # genePair fixes
               genePair = str_trim(genePair),
               # Match only the first entry
               genePair = gsub("/.*$", "", genePair),
               # Remove trailing info, e.g. `(dbd)`
               genePair = gsub("\\(.+\\)$", "", genePair)) %>%
        filter(!is.na(genePair)) %>%
        select(cherrypickId, genePair, ahringer96, orfeome96) %>%
        arrange(cherrypickId)
}
cherrypick <- bind_rows(raw) %>% arrange(cherrypickId)
save(cherrypick, file = "data-raw/cherrypick.rda")
