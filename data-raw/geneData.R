library(dplyr)
library(magrittr)
library(seqcloudr)

# Wormbase ====
load("data-raw/wormbase.rda")
if (!exists("wormbase")) {
    source("data-raw/wormbase.R")
}
wormbase <- Reduce(function(...) dplyr::full_join(..., by = "gene"),
                   wormbase)


# Ensembl ====
load("data-raw/ensembl.rda")
if (!exists("ensembl")) {
    source("data-raw/ensembl.R")
}
ensembl <- Reduce(function(...) dplyr::full_join(..., by = "ensembl_gene_id"),
                  ensembl) %>%
    dplyr::rename(gene = ensembl_gene_id) %>%
    magrittr::set_names(seqcloudr::camel(names(.)))


# PANTHER ====
load("data-raw/panther.rda")
if (!exists("panther")) {
    source("data-raw/panther.R")
}
names(panther)[2:length(panther)] <-
    paste("panther", names(panther)[2:length(panther)], sep = "_") %>%
    seqcloudr::camel(.)


# Join And Save ====
geneData <- Reduce(function(...) dplyr::left_join(..., by = "gene"),
                   list(wormbase, ensembl, panther)) %>%
    seqcloudr::cruft(.) %>%
    dplyr::select(noquote(order(names(.)))) %>%
    dplyr::arrange(gene)
devtools::use_data(geneData, overwrite = TRUE)
