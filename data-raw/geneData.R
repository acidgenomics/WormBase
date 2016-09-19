library(dplyr)
library(magrittr)
library(seqcloudr)

# Wormbase ====
load("data-raw/wormbase.rda")
if (!exists("wormbase")) {
    source("data-raw/wormbase.R")
}
wormbase <- Reduce(function(...) full_join(..., by = "gene"),
                   wormbase)


# Ensembl ====
load("data-raw/ensembl.rda")
if (!exists("ensembl")) {
    source("data-raw/ensembl.R")
}
ensembl <- Reduce(function(...) full_join(..., by = "ensembl_gene_id"),
                  ensembl) %>%
    rename(gene = ensembl_gene_id) %>%
    set_names(camel(names(.)))


# PANTHER ====
load("data-raw/panther.rda")
if (!exists("panther")) {
    source("data-raw/panther.R")
}
names(panther)[2:length(panther)] <-
    paste("panther", names(panther)[2:length(panther)], sep = "_") %>%
    camel


# Join And Save ====
geneData <- Reduce(function(...) left_join(..., by = "gene"),
                   list(wormbase, ensembl, panther)) %>%
    cruft %>%
    select(noquote(order(names(.)))) %>%
    arrange(gene)
devtools::use_data(geneData, overwrite = TRUE)
