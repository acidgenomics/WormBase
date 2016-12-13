# \code{external_gene_name} = Ensembl public name
# \code{wormbase_locus} = WormBase public name
# \code{wormbase_gene_seq_name} for clean sequence identifier.

library(biomaRt) # note that biomaRt masks dplyr::select
mart <- useMart("ensembl", dataset = "celegans_gene_ensembl")
options <- listAttributes(mart)

basic <-
    getBM(mart = mart,
          attributes = c("ensembl_gene_id",
                         "description",
                         "gene_biotype",
                         "chromosome_name",
                         "start_position",
                         "end_position",
                         "strand")) %>%
    rename(biotype = gene_biotype,
           chromosome = chromosome_name)

geneOntology <-
    getBM(mart = mart,
          attributes = c("ensembl_gene_id",
                         "go_id",
                         "name_1006")) %>%
    group_by(ensembl_gene_id) %>%
    mutate(gene_ontology = paste(go_id, name_1006, sep = "~")) %>%
    mutate(gene_ontology = gsub("^~$", NA, gene_ontology)) %>%
    summarize(gene_ontology = toString(gene_ontology))

interpro <-
    getBM(mart = mart,
          attributes = c("ensembl_gene_id",
                         "interpro",
                         "interpro_description")) %>%
    group_by(ensembl_gene_id) %>%
    mutate(interpro = paste(interpro, interpro_description, sep = "~")) %>%
    mutate(interpro = gsub("^~$", NA, interpro)) %>%
    summarize(interpro = toString(interpro))

ensembl <-
    Reduce(function(...) { full_join(..., by = "ensembl_gene_id") },
           list(basic,
                geneOntology,
                interpro)) %>%
    rename(gene = ensembl_gene_id) %>%
    as_tibble %>%
    wash %>%
    setNamesCamel

use_data(ensembl, overwrite = TRUE)
detach("package:biomaRt", unload = TRUE)
rm(basic, geneOntology, interpro, mart, options)
