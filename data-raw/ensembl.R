# \code{external_gene_name} = Ensembl public name
# \code{wormbase_locus} = WormBase public name
# \code{wormbase_gene_seq_name} for clean sequence identifier.
library(biomaRt)
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
                                  "description")) %>%
    dplyr::rename(biotype = gene_biotype,
                  chromosome = chromosome_name,
                  description_ensembl = description,
                  position_start = start_position,
                  position_end = end_position)


# Gene Ontology ====
ensembl[["go"]] <-
    biomaRt::getBM(mart = mart,
                   attributes = c("ensembl_gene_id",
                                  "go_id",
                                  "name_1006")) %>%
    dplyr::group_by(ensembl_gene_id) %>%
    dplyr::summarize(gene_ontology = toString(sort(unique(stats::na.omit(go_id)))),
                     gene_ontology_name = toString(sort(unique(stats::na.omit(name_1006)))))


# Interpro ====
ensembl[["interpro"]] <-
    biomaRt::getBM(mart = mart,
                   attributes = c("ensembl_gene_id",
                                  "interpro",
                                  "interpro_description")) %>%
    dplyr::group_by(ensembl_gene_id) %>%
    dplyr::summarize(interpro = toString(sort(unique(stats::na.omit(interpro)))),
                     interpro_name = toString(sort(unique(stats::na.omit(interpro_description)))))


# Save ====
save(ensembl, file = "data-raw/ensembl.rda")
