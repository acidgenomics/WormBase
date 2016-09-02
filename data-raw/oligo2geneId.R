library(dplyr)
library(readr)
source("R/wormbaseFile.R")
oligo2geneId <- wormbaseFile("pcr_product2gene") %>%
    read_tsv(col_names = c("oligo", "oligo2geneId")) %>%
    mutate(oligo2geneId = gsub("^(WBGene[0-9]+).*", "\\1", oligo2geneId))
devtools::use_data(oligo2geneId, overwrite = TRUE)
