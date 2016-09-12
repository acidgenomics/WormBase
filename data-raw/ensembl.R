#' \code{external_gene_name} = Ensembl public name
#' \code{wormbase_locus} = WormBase public name
#' \code{wormbase_gene_seq_name} for clean sequence identifier.
library(dplyr)
ensembl <- list()
mart <- biomaRt::useMart("ENSEMBL_MART_ENSEMBL", "celegans_gene_ensembl", host = "useast.ensembl.org")
options <- biomaRt::listAttributes(mart)

# Simple gene length info ====
ensembl[["basic"]] <-
    biomaRt::getBM(mart = mart,
                   attributes = c("ensembl_gene_id",
                                  "gene_biotype",
                                  "chromosome_name",
                                  "start_position",
                                  "end_position",
                                  "strand",
                                  "description"))

# Homology ====
ensembl[["homology"]] <-
    biomaRt::getBM(mart = mart,
                   attributes = c("ensembl_gene_id",
                                  "hsapiens_homolog_ensembl_gene")) %>%
    dplyr::group_by(ensembl_gene_id) %>%
    dplyr::summarize(hsapiens_homolog_ensembl_gene = paste(sort(unique(hsapiens_homolog_ensembl_gene)),
                                                           collapse = ", "))

# Gene Ontology ====
ensembl[["geneOntology"]] <-
    biomaRt::getBM(mart = mart,
                   attributes = c("ensembl_gene_id",
                                  "go_id",
                                  "name_1006")) %>%
    dplyr::group_by(ensembl_gene_id) %>%
    dplyr::summarize(gene_ontology_name = paste(sort(unique(name_1006)),
                                                collapse = ", "),
                     gene_ontology_id = paste(sort(unique(go_id)),
                                              collapse = ", "))

# Interpro ====
ensembl[["interpro"]] <-
    biomaRt::getBM(mart = mart,
                   attributes = c("ensembl_gene_id",
                                  "interpro",
                                  "interpro_description")) %>%
    dplyr::group_by(ensembl_gene_id) %>%
    dplyr::summarize(interpro_id = paste(sort(unique(stats::na.omit(interpro))),
                                         collapse = ", "),
                     interpro_description = paste(sort(unique(interpro_description)),
                                                  collapse = ", "))

# Save ====
devtools::use_data(ensembl, overwrite = TRUE)
