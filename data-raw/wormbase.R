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
geneIds <- wormbaseFile("geneIDs") %>%
  read_csv(col_names = c("X", "geneId", "publicName", "orf", "status"), na = "") %>%
  select(-1)
geneOtherIds <- wormbaseFile("geneOtherIDs") %>%
  read_file %>%
  # Take out dead or live status, we have this already from geneIds
  gsub("\t(Dead|Live)", "", .) %>%
  # Take the tabs out for gene list
  gsub("\t", ", ", .) %>%
  # Add tab back in to separate geneId for row names
  gsub("WBGene([0-9]+), ", "WBGene\\1\t", .) %>%
  # Warnings here mean there are no other IDs for that row
  # (e.g. expected: 2 columns, actual: 1 columns)
  read_tsv(col_names = c("geneId", "geneOtherIds"))
wormbase[["geneId"]] <- left_join(geneIds, geneOtherIds)
rm(geneIds, geneOtherIds)


# Functional Descriptions ====
file <- wormbaseFile("functional_descriptions")
names <- read_lines(file, n_max = 1, skip = 3) %>%
  str_split(" ") %>%
  .[[1]] %>%
  camel
wormbase[["description"]] <-
  read_delim(file, delim = "\t", col_names = names, skip = 4, na = c("", "none available", "not known")) %>%
  select(-c(molecularName, publicName)) %>%
  filter(grepl("^WBGene[0-9]+$", geneId))
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
raw <- read_tsv("data-raw/wormbase/rnai_phenotypes.tsv", col_names = c("geneId", "orf", "unsorted"))
wormbase[["rnaiPhenotypes"]] <- mclapply(seq_along(rownames(raw)), function(i) {
  str_split(as.character(raw[i, "unsorted"]), ", ") %>%
    .[[1]] %>%
    unique %>%
    sort %>%
    paste(collapse = ", ")
  }) %>%
  unlist %>% tibble(rnaiPhenotypes = .) %>%
  bind_cols(raw, .) %>%
  select(-c(orf, unsorted))
rm(raw)


# Orthologs ====
raw <- wormbaseFile("orthologs") %>%
  read_file %>%
  gsub("\t", " | ", .) %>%
  gsub("\n", " // ", .) %>%
  gsub("= // ", "\n", .) %>%
  gsub(" //  // ", "\t", .) %>%
  read_tsv(comment = "#", col_names = c("geneId", "orthologs")) %>%
  mutate(geneId = gsub("^(WBGene[0-9]+).*", "\\1", geneId))
list <- split(raw, seq(nrow(raw)))
hsapiens <-
  mclapply(seq_along(list), function(x) {
    str_split(list[[x]][2], " // ")[[1]] %>%
      str_subset("Homo sapiens") %>%
      str_extract("ENSG[0-9]+") %>%
      sort %>%
      unique %>%
      paste(collapse = ", ")
  }) %>%
  unlist
wormbase[["orthologs"]] <- tibble(geneId = raw[[1]], hsapiensEnsemblGeneId = hsapiens)
rm(list, raw)


# Best BLASTP Hits ====
# Get the highest match for each peptide:
blastp <- wormbaseFile("best_blast_hits") %>%
  read_csv(col_names = FALSE) %>%
  select(X1, X4, X5) %>%
  rename(wormpepId = X1, ensemblPeptideId = X4, eValue = X5) %>%
  filter(grepl("^ENSEMBL", ensemblPeptideId)) %>%
  mutate(ensemblPeptideId = str_sub(ensemblPeptideId, 9)) %>%
  arrange(wormpepId, eValue) %>%
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
wormpepId <- read_lines(file) %>%
  str_split("\n") %>%
  mclapply(., function(x) {
    gsub("^.*\t(CE[0-9]+\tWBGene[0-9]+).*$", "\\1", x) %>%
      str_split("\t") %>%
      .[[1]]
  }) %>%
  do.call(rbind, .) %>%
  as_tibble %>%
  setNames(c("wormpepId", "geneId"))

# Bind the WormBase Gene IDs:
blastp <- left_join(blastp, wormpepId, by = "wormpepId", all = TRUE) %>%
  arrange(geneId, eValue, wormpepId) %>%
  distinct(geneId, .keep_all = TRUE) %>%
  na.omit
rm(wormpepId)

# Map Ensembl Peptide IDs:
mart <- biomaRt::useMart("ENSEMBL_MART_ENSEMBL", "hsapiens_gene_ensembl", host = "useast.ensembl.org")
options <- biomaRt::listAttributes(mart)
hsapiens <-
  biomaRt::getBM(mart = mart,
                 filters = "ensembl_peptide_id",
                 values = blastp$ensemblPeptideId,
                 attributes = c("ensembl_peptide_id",
                                "ensembl_gene_id",
                                "external_gene_name",
                                "description")) %>%
  rename(hsapiensBlastpDescription = description,
         hsapiensBlastpGeneName = external_gene_name,
         hsapiensBlastpGeneId = ensembl_gene_id) %>%
  setNames(camel(names(.)))

# Final join:
wormbase[["blastp"]] <- left_join(blastp, hsapiens, by = "ensemblPeptideId")
rm(blastp, file, hsapiens, mart, options)


# Save ====
devtools::use_data(wormbase, overwrite = TRUE)
