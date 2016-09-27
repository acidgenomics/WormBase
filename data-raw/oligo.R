oligo <- wormbaseFile("pcr_product2gene") %>%
    readr::read_tsv(., col_names = c("oligo", "gene")) %>%
    dplyr::mutate(gene = stringr::str_extract(gene, "WBGene\\d{8}"))
save(oligo, file = "data-raw/oligo.rda")
