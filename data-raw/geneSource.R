library(devtools)
library(dplyr)
library(seqcloudr)

# Wormbase ====
data(wormbaseFtp, wormbaseGeneExternal)
if (!exists("wormbaseFtp")) {
    source("data-raw/wormbaseFtp.R")
}
if (!exists("wormbaseGeneExternal")) {
    source("data-raw/wormbaseGeneExternal.R")
}
wormbase <- Reduce(function(...) dplyr::full_join(..., by = "gene"), wormbaseFtp) %>%
    dplyr::full_join(., wormbaseGeneExternal, by = "gene")


# Ensembl ====
data(ensembl)
if (!exists("ensembl")) {
    source("data-raw/ensembl.R")
}
ensembl <- Reduce(function(...) dplyr::full_join(..., by = "ensembl_gene_id"), ensembl) %>%
    dplyr::rename(gene = ensembl_gene_id) %>%
    stats::setNames(., seqcloudr::camel(names(.)))


# PANTHER ====
data(panther)
if (!exists("panther")) {
    source("data-raw/panther.R")
}
names(panther)[2:length(panther)] <-
    paste("panther", names(panther)[2:length(panther)], sep = "_") %>%
    seqcloudr::camel(.)


# Join And Save ====
geneSource <- Reduce(function(...) dplyr::left_join(..., by = "gene"),
                   list(wormbase, ensembl, panther)) %>%
    dplyr::select(noquote(order(names(.)))) %>%
    dplyr::arrange(gene)
devtools::use_data(geneSource, overwrite = TRUE)
