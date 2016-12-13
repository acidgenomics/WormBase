wormbaseOligo <- wormbaseAnnotationFile("pcr_product2gene") %>%
    read_tsv(col_names = c("oligo", "gene")) %>%
    mutate(gene = str_extract(gene, "WBGene\\d{8}"))
use_data(wormbaseOligo, overwrite = TRUE)
