library(dplyr)
library(readr)
source("R/wormbaseFile.R")
oligo2geneId <- wormbaseFile("pcr_product2gene") %>%
    read_tsv(col_names = c("oligo", "geneId")) %>%
    mutate(geneId = gsub("^(WBGene[0-9]+).*", "\\1", geneId))
save(oligo2geneId, file = "data-raw/oligo2geneId.rda")
