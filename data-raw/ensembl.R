# \code{external_gene_name} = Ensembl public name
# \code{wormbase_locus} = WormBase public name
# \code{wormbase_gene_seq_name} for clean sequence identifier.
library(biomaRt)
library(dplyr)

ensembl <- list()
mart <- biomaRt::useMart("ensembl", dataset = "celegans_gene_ensembl")
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
    dplyr::summarize(gene_ontology = seqcloudr::toString(go_id),
                     gene_ontology_name = paste(name_1006, collapse = " / "))


# Interpro ====
ensembl[["interpro"]] <-
    biomaRt::getBM(mart = mart,
                   attributes = c("ensembl_gene_id",
                                  "interpro",
                                  "interpro_description")) %>%
    dplyr::group_by(ensembl_gene_id) %>%
    dplyr::summarize(interpro = seqcloudr::toString(interpro),
                     interpro_name = seqcloudr::toString(interpro_description))


# Save ====
save(ensembl, file = "data-raw/ensembl.rda")
