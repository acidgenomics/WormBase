# library(biomaRt) - conflicts with dplyr
library(dplyr)
library(magrittr)
library(parallel)
library(RCurl)
library(readr)
library(seqcloudr)
library(stringr)
library(tibble)
devtools::load_all()

wormbase <- list()

# Gene Identifiers ====
gene <- wormbaseFile("geneIDs") %>%
    read_csv(col_names = c("X", "gene", "name", "sequence", "status"), na = "") %>%
    select(-1)
geneOtherIdentifier <- wormbaseFile("geneOtherIDs") %>%
    read_file %>%
    # Take out dead or live status, we have this already from \code{wormbase$gene}
    gsub("\t(Dead|Live)", "", .) %>%
    # Take the tabs out for gene list
    gsub("\t", ", ", .) %>%
    # Add tab back in to separate \code{gene} for row names
    gsub("WBGene([0-9]+), ", "WBGene\\1\t", .) %>%
    # Warnings here mean there are no other IDs for that row
    # (e.g. expected: 2 columns, actual: 1 columns)
    read_tsv(col_names = c("gene", "otherIdentifier"))
wormbase[["gene"]] <- left_join(gene, geneOtherIdentifier, by = "gene")
rm(gene, geneOtherIdentifier)


# Functional Descriptions ====
file <- wormbaseFile("functional_descriptions")
names <- read_lines(file, n_max = 1, skip = 3) %>%
    str_split(" ") %>% .[[1]] %>%
    str_replace("(\\w+)_description$", "description_\\1") %>%
    camel %>%
    str_replace("descriptionGeneClass", "class") %>%
    str_replace("geneId", "gene") %>%
    str_replace("molecularName", "sequence") %>%
    str_replace("publicName", "name")
print(names)
wormbase[["description"]] <-
    read_delim(file, delim = "\t", col_names = names, skip = 4, na = c("", "none available", "not known")) %>%
    select(-c(name, sequence)) %>%
    filter(grepl("^WBGene[0-9]+$", gene))
rm(file, names)


# RNAi Phenotypes ====
if (!file.exists("data-raw/wormbase/rnai_phenotypes.tsv")) {
    dir <- "ftp://ftp.wormbase.org/pub/wormbase/releases/current-production-release/ONTOLOGY/"
    file <- getURL(dir, dirlistonly = TRUE) %>%
        str_split("\n") %>%
        .[[1]] %>%
        str_subset("rnai_phenotypes_quick") %>%
        paste0(dir, .)
    download.file(file, "data-raw/wormbase/rnai_phenotypes.tsv")
    rm(dir, file)
}
raw <- read_tsv("data-raw/wormbase/rnai_phenotypes.tsv", col_names = c("gene", "sequence", "unsorted"))
wormbase[["rnai"]] <-
    parallel::mclapply(seq_along(rownames(raw)), function(i) {
        str_split(as.character(raw[i, "unsorted"]), ", ") %>%
            .[[1]] %>% unique %>% sort %>% toString
    }) %>%
    unlist %>%
    tibble(rnaiPhenotypes = .) %>%
    bind_cols(raw, .) %>%
    select(-c(sequence, unsorted))
rm(raw)


# Orthologs ====
raw <- wormbaseFile("orthologs") %>%
    read_file %>%
    gsub("\t", " | ", .) %>%
    gsub("\n", " // ", .) %>%
    gsub("= // ", "\n", .) %>%
    gsub(" //  // ", "\t", .) %>%
    read_tsv(comment = "#", col_names = c("gene", "ortholog")) %>%
    mutate(gene = gsub("^(WBGene[0-9]+).*", "\\1", gene))
list <- split(raw, seq(nrow(raw)))
hsapiens <-
    parallel::mclapply(seq_along(list), function(x) {
        str_split(list[[x]][2], " // ")[[1]] %>%
            str_subset("Homo sapiens") %>%
            str_extract("ENSG[0-9]+") %>%
            unique %>% sort %>% toString
    }) %>%
    unlist
wormbase[["ortholog"]] <- tibble(gene = raw[[1]], hsapiensGene = hsapiens)
rm(list, raw)


# Best BLASTP Hits ====
# Get the highest match for each peptide:
blastp <- wormbaseFile("best_blast_hits") %>%
    read_csv(col_names = FALSE) %>%
    select(X1, X4, X5) %>%
    rename(wormpep = X1, peptide = X4, eValue = X5) %>%
    filter(grepl("^ENSEMBL", peptide)) %>%
    mutate(peptide = str_sub(peptide, 9)) %>%
    arrange(wormpep, eValue) %>%
    distinct

# Wormpep IDs are used for BLASTP matching:
if (!file.exists("data-raw/wormbase/wormpep.tar.gz")) {
    dir <- "ftp://ftp.wormbase.org/pub/wormbase/releases/current-production-release/species/c_elegans/PRJNA13758/"
    file <- getURL(dir, dirlistonly = TRUE) %>%
        str_split("\n") %>%
        .[[1]] %>%
        str_subset("wormpep_package") %>%
        as.character %>%
        paste0(dir, .)
    download.file(file, "data-raw/wormbase/wormpep.tar.gz")
}
file <- list.files(path = "data-raw/wormbase", pattern = "wormpep.table", full.names = TRUE)
if (length(file) == 0) {
    untar("data-raw/wormbase/wormpep.tar.gz", exdir = "data-raw/wormbase", files = "wormpep.table*")
    file <- list.files(path = "data-raw/wormbase", pattern = "wormpep.table", full.names = TRUE)
}
wormpep <- read_lines(file) %>%
    str_split("\n") %>%
    parallel::mclapply(., function(x) {
        gsub("^.*\t(CE[0-9]+\tWBGene[0-9]+).*$", "\\1", x) %>%
            str_split("\t") %>% .[[1]]
    }) %>%
    do.call(rbind, .) %>%
    as_tibble %>%
    set_names(c("wormpep", "gene"))

# Bind the WormBase Gene IDs:
blastp <- left_join(blastp, wormpep, by = "wormpep", all = TRUE) %>%
    arrange(gene, eValue, wormpep) %>%
    distinct(gene, .keep_all = TRUE) %>%
    na.omit %>%
    select(-eValue)
rm(wormpep)

# Map Ensembl Peptide IDs:
mart <- biomaRt::useMart("ENSEMBL_MART_ENSEMBL", "hsapiens_gene_ensembl", host = "useast.ensembl.org")
options <- biomaRt::listAttributes(mart)
blastpHsapiens <-
    biomaRt::getBM(mart = mart,
                   filters = "ensembl_peptide_id",
                   values = blastp$peptide,
                   attributes = c("ensembl_peptide_id",
                                  "ensembl_gene_id",
                                  "external_gene_name",
                                  "description")) %>%
    rename(peptide = ensembl_peptide_id,
           blastpHsapiensDescription = description,
           blastpHsapiensGene = ensembl_gene_id,
           blastpHsapiensName = external_gene_name)

# Final join:
wormbase[["blastp"]] <- left_join(blastp, blastpHsapiens, by = "peptide")
rm(blastp, blastpHsapiens, file, mart, options)


# External Identifiers ====
wormbase[["external"]] <- wormbaseRestGeneExternal(wormbase$gene$gene)


# Save ====
save(wormbase, file = "data-raw/wormbase.rda")
