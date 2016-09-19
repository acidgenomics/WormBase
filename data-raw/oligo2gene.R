library(dplyr)
library(readr)
library(stringr)
devtools::load_all()
oligo2gene <- wormbaseFile("pcr_product2gene") %>%
    readr::read_tsv(., col_names = c("oligo", "gene")) %>%
    dplyr::mutate(gene = str_extract(gene, "WBGene\\d{8}"))
save(oligo2gene, file = "data-raw/oligo2gene.rda")
