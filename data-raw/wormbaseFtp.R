source("R/wormbaseFtp.R")

library(biomaRt) # conflicts with dplyr
library(dplyr)
library(parallel)
library(RCurl)
library(readr)
library(R.utils)
library(seqcloudr)
library(stringr)
library(tibble)

wormbaseFtp <- list()


# Oligo Identifiers ====
wormbaseFtpOligo <- wormbaseFtpFile("pcr_product2gene") %>%
    readr::read_tsv(., col_names = c("oligo", "gene")) %>%
    dplyr::mutate(gene = stringr::str_extract(gene, "WBGene\\d{8}"))
devtools::use_data(wormbaseFtpOligo, overwrite = TRUE)


# Gene Identifiers ====
gene <- wormbaseFtpFile("geneIDs") %>%
    readr::read_csv(.,
                    col_names = c("X", "gene", "name", "sequence", "status"),
                    na = "") %>%
    dplyr::select(-1)
geneOtherIdentifier <- wormbaseFtpFile("geneOtherIDs") %>%
    readr::read_file(.) %>%
    # Take out dead or live status, we have this already from \code{wormbase$gene}:
    gsub("\t(Dead|Live)", "", .) %>%
    # Take the tabs out for gene list:
    gsub("\t", ", ", .) %>%
    # Add tab back in to separate \code{gene} for row names:
    gsub("WBGene([0-9]+), ", "WBGene\\1\t", .) %>%
    # Warnings here mean there are no other IDs for that row:
    # (e.g. expected: 2 columns, actual: 1 columns)
    readr::read_tsv(., col_names = c("gene", "otherIdentifier"))
wormbaseFtp[["gene"]] <- dplyr::left_join(gene, geneOtherIdentifier, by = "gene")
rm(gene, geneOtherIdentifier)


# Functional Descriptions ====
file <- wormbaseFtpFile("functional_descriptions")
names <- readr::read_lines(file, n_max = 1, skip = 3) %>%
    stringr::str_split(., " ") %>%
    .[[1]] %>%
    stringr::str_replace(., "(\\w+)_description$", "description_\\1") %>%
    seqcloudr::camel(.) %>%
    stringr::str_replace(., "descriptionGeneClass", "class") %>%
    stringr::str_replace(., "geneId", "gene") %>%
    stringr::str_replace(., "molecularName", "sequence") %>%
    stringr::str_replace(., "publicName", "name")
print(names)
wormbaseFtp[["description"]] <-
    readr::read_delim(file, delim = "\t",
                      col_names = names,
                      skip = 4,
                      na = c("", "none available", "not known")) %>%
    dplyr::select(-c(name, sequence)) %>%
    dplyr::filter(grepl("^WBGene[0-9]+$", gene))
rm(file, names)


# RNAi Phenotypes ====
fileLocal <- "data-raw/wormbase/rnai_phenotypes.tsv.gz"
if (!file.exists(fileLocal)) {
    dir <- "ftp://ftp.wormbase.org/pub/wormbase/releases/current-production-release/ONTOLOGY/"
    fileRemote <- RCurl::getURL(dir, dirlistonly = TRUE) %>%
        stringr::str_split(., "\n") %>%
        .[[1]] %>%
        stringr::str_subset(., "rnai_phenotypes_quick") %>%
        paste0(dir, .)
    fileLocal <- "data-raw/wormbase/rnai_phenotypes.tsv"
    utils::download.file(fileRemote, fileLocal)
    rm(dir, fileRemote)
}
R.utils::gzip(fileLocal, overwrite = TRUE)
fileLocal <- paste0(fileLocal, ".gz")
wormbaseFtp[["rnai"]] <- readr::read_tsv(fileLocal,
                                         col_names = c("gene",
                                                       "sequence",
                                                       "rnaiPhenotypes")) %>%
    dplyr::select(-sequence)


# Orthologs ====
raw <- wormbaseFtpFile("orthologs") %>%
    readr::read_file(.) %>%
    gsub("\t", " | ", .) %>%
    gsub("\n", " // ", .) %>%
    gsub("= // ", "\n", .) %>%
    gsub(" //  // ", "\t", .) %>%
    readr::read_tsv(.,
                    comment = "#",
                    col_names = c("gene", "ortholog")) %>%
    dplyr::mutate(gene = gsub("^(WBGene[0-9]+).*", "\\1", gene))
list <- split(raw, seq(nrow(raw)))
hsapiens <-
    parallel::mclapply(seq_along(list), function(x) {
        stringr::str_split(list[[x]][2], " // ")[[1]] %>%
            stringr::str_subset(., "Homo sapiens") %>%
            stringr::str_extract(., "ENSG[0-9]+") %>%
            seqcloudr::toStringUnique(.)
    }) %>%
    unlist(.)
wormbaseFtp[["ortholog"]] <-
    tibble::tibble(gene = raw[[1]], hsapiensGene = hsapiens)
rm(hsapiens, list, raw)


# Best BLASTP Hits ====
# Get the highest match for each peptide:
blastp <- wormbaseFtpFile("best_blast_hits") %>%
    readr::read_csv(., col_names = FALSE) %>%
    dplyr::select(X1, X4, X5) %>%
    dplyr::rename(wormpep = X1, peptide = X4, eValue = X5) %>%
    dplyr::filter(grepl("^ENSEMBL", peptide)) %>%
    dplyr::mutate(peptide = stringr::str_sub(peptide, 9)) %>%
    dplyr::arrange(wormpep, eValue) %>%
    dplyr::distinct(.)

# Wormpep IDs are used for BLASTP matching:
fileLocal <- "data-raw/wormbase/wormpep.tsv.gz"
if (!file.exists(fileLocal)) {
    dir <- "ftp://ftp.wormbase.org/pub/wormbase/releases/current-production-release/species/c_elegans/PRJNA13758/"
    fileRemote <- RCurl::getURL(dir, dirlistonly = TRUE) %>%
        stringr::str_split(., "\n") %>%
        .[[1]] %>%
        stringr::str_subset(., "wormpep_package") %>%
        as.character(.) %>%
        paste0(dir, .)
    utils::download.file(fileRemote, fileLocal)
    utils::untar(fileLocal,
                 exdir = "data-raw/wormbase",
                 files = "wormpep.table*")
    # Safe to delete the large source file:
    unlink(fileLocal)
    fileLocal <- list.files(path = "data-raw/wormbase",
                       pattern = "wormpep.table",
                       full.names = TRUE)
    fileRename <- "data-raw/wormbase/wormpep.tsv"
    file.rename(fileLocal, fileRename)
    fileLocal <- fileRename
    rm(fileRename)
    R.utils::gzip(fileLocal, overwrite = TRUE)
    fileLocal <- paste0(fileLocal, ".gz")
}
wormpep <- readr::read_lines(fileLocal) %>%
    stringr::str_split(., "\n") %>%
    parallel::mclapply(., function(x) {
        gsub("^.*\t(CE[0-9]+\tWBGene[0-9]+).*$", "\\1", x) %>%
            stringr::str_split(., "\t") %>% .[[1]]
    }) %>%
    do.call(rbind, .) %>%
    tibble::as_tibble(.) %>%
    stats::setNames(., c("wormpep", "gene"))

# Bind the WormBase Gene IDs:
blastp <- dplyr::left_join(blastp, wormpep, by = "wormpep", all = TRUE) %>%
    dplyr::arrange(gene, eValue, wormpep) %>%
    dplyr::distinct(gene, .keep_all = TRUE) %>%
    stats::na.omit(.) %>%
    dplyr::select(-eValue)
rm(wormpep)

# Map Ensembl Peptide IDs:
mart <- biomaRt::useMart("ensembl", dataset = "hsapiens_gene_ensembl")
options <- biomaRt::listAttributes(mart)
blastpHsapiens <-
    biomaRt::getBM(mart = mart,
                   filters = "ensembl_peptide_id",
                   values = blastp$peptide,
                   attributes = c("ensembl_peptide_id",
                                  "ensembl_gene_id",
                                  "external_gene_name",
                                  "description")) %>%
    dplyr::rename(peptide = ensembl_peptide_id,
                  blastpHsapiensDescription = description,
                  blastpHsapiensGene = ensembl_gene_id,
                  blastpHsapiensName = external_gene_name)

# Final join:
wormbaseFtp[["blastp"]] <- dplyr::left_join(blastp, blastpHsapiens, by = "peptide")
rm(blastp, blastpHsapiens, file, mart, options)


# Save ====
devtools::use_data(wormbaseFtp, overwrite = TRUE)
