library(dplyr)
library(readr)
oligo2geneId <- wormbaseFile("pcr_product2gene") %>%
    read_tsv(col_names = c("oligo", "geneId")) %>%
    mutate(geneId = gsub("^(WBGene[0-9]+).*", "\\1", geneId))
devtools::use_data(oligo2geneId, overwrite = TRUE)
