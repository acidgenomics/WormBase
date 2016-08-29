#' \code{entrezgene} = Entrez identifier
#' \code{external_gene_name} = Ensembl public name
#' \code{wormbase_locus} = WormBase public name
#'
#' Use \code{wormbase_gene_seq_name} for clean sequence identifier.
#'
#' Don't load biomaRt here, it conflicts with \code{select} in dplyr.
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

# Identifiers ====
bm1 <-
  biomaRt::getBM(mart = mart,
                 attributes = c("ensembl_gene_id",
                                "refseq_mrna",
                                "refseq_ncrna"))
bm2 <-
  biomaRt::getBM(mart = mart,
                 attributes = c("ensembl_gene_id",
                                "uniprot_sptrembl",
                                "uniprot_swissprot"))
bm3 <-
  biomaRt::getBM(mart = mart,
                 attributes = c("ensembl_gene_id",
                                "entrezgene",
                                "kegg_enzyme"))
ensembl[["otherIds"]] <-
  Reduce(function(...) full_join(..., by = "ensembl_gene_id"), list(bm1, bm2, bm3)) %>%
  group_by(ensembl_gene_id) %>%
  summarize(entrez_gene_id = paste(sort(unique(entrezgene)), collapse = ", "),
            kegg_enzyme = paste(sort(unique(kegg_enzyme)), collapse = ", "),
            refseq_mrna = paste(sort(unique(refseq_mrna)), collapse = ", "),
            refseq_ncrna = paste(sort(unique(refseq_ncrna)), collapse = ", "),
            uniprot_sptrembl = paste(sort(unique(uniprot_sptrembl)), collapse = ", "),
            uniprot_swissprot = paste(sort(unique(uniprot_swissprot)), collapse = ", "))
rm(bm1, bm2, bm3)

# Homology ====
ensembl[["homology"]] <-
  biomaRt::getBM(mart = mart,
                 attributes = c("ensembl_gene_id",
                                "hsapiens_homolog_ensembl_gene")) %>%
  group_by(ensembl_gene_id) %>%
  summarize(hsapiens_homolog_ensembl_gene = paste(sort(unique(hsapiens_homolog_ensembl_gene)), collapse = ", "))

# Gene Ontology ====
ensembl[["geneOntology"]] <-
  biomaRt::getBM(mart = mart,
                 attributes = c("ensembl_gene_id",
                                "go_id",
                                "name_1006")) %>%
  group_by(ensembl_gene_id) %>%
  summarize(gene_ontology_name = paste(sort(unique(name_1006)), collapse = ", "),
            gene_ontology_id = paste(sort(unique(go_id)), collapse = ", "))

# Interpro ====
ensembl[["interpro"]] <-
  biomaRt::getBM(mart = mart,
                 attributes = c("ensembl_gene_id",
                                "interpro",
                                "interpro_description")) %>%
  group_by(ensembl_gene_id) %>%
  summarize(interpro_id = paste(sort(unique(interpro)),collapse = ", "),
            interpro_description = paste(sort(unique(interpro_description)), collapse = ", "))

# Save ====
devtools::use_data(ensembl, overwrite = TRUE)
