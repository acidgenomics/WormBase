# \code{external_gene_name} = Ensembl public name
# \code{wormbase_locus} = WormBase public name
# \code{wormbase_gene_seq_name} for clean sequence identifier.

#! library(biomaRt) - conflicts with dplyr
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
    rename(biotype = gene_biotype,
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
    group_by(ensembl_gene_id) %>%
    summarize(gene_ontology = na.omit(unique(sort(toString(go_id)))),
              gene_ontology_name = na.omit(unique(sort(toString(name_1006)))))


# Interpro ====
ensembl[["interpro"]] <-
    biomaRt::getBM(mart = mart,
                   attributes = c("ensembl_gene_id",
                                  "interpro",
                                  "interpro_description")) %>%
    group_by(ensembl_gene_id) %>%
    summarize(interpro = na.omit(unique(sort(toString(interpro)))),
              interpro_name = na.omit(unique(sort(toString(interpro_description)))))


# Save ====
save(ensembl, file = "data-raw/ensembl.rda")
