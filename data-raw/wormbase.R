devtools::load_all()
library(biomaRt) # conflicts with dplyr
library(dplyr)
library(parallel)
library(RCurl)
library(readr)
library(seqcloudr)
library(stringr)
library(tibble)
wormbase <- list()


# Gene Identifiers ====
gene <- wormbaseFile("geneIDs") %>%
    readr::read_csv(.,
                    col_names = c("X", "gene", "name", "sequence", "status"),
                    na = "") %>%
    dplyr::select(-1)
geneOtherIdentifier <- wormbaseFile("geneOtherIDs") %>%
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
wormbase[["gene"]] <- dplyr::left_join(gene, geneOtherIdentifier, by = "gene")
rm(gene, geneOtherIdentifier)


# Functional Descriptions ====
file <- wormbaseFile("functional_descriptions")
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
wormbase[["description"]] <-
    readr::read_delim(file, delim = "\t",
                      col_names = names,
                      skip = 4,
                      na = c("", "none available", "not known")) %>%
    dplyr::select(-c(name, sequence)) %>%
    dplyr::filter(grepl("^WBGene[0-9]+$", gene))
rm(file, names)


# RNAi Phenotypes ====
if (!file.exists("data-raw/wormbase/rnai_phenotypes.tsv")) {
    dir <- "ftp://ftp.wormbase.org/pub/wormbase/releases/current-production-release/ONTOLOGY/"
    file <- RCurl::getURL(dir, dirlistonly = TRUE) %>%
        stringr::str_split(., "\n") %>%
        .[[1]] %>%
        stringr::str_subset(., "rnai_phenotypes_quick") %>%
        paste0(dir, .)
    utils::download.file(file, "data-raw/wormbase/rnai_phenotypes.tsv")
    rm(dir, file)
}
wormbase[["rnai"]] <- readr::read_tsv("data-raw/wormbase/rnai_phenotypes.tsv",
                                      col_names = c("gene", "sequence", "rnaiPhenotypes")) %>%
    dplyr::select(-sequence)


# Orthologs ====
raw <- wormbaseFile("orthologs") %>%
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
wormbase[["ortholog"]] <-
    tibble::tibble(gene = raw[[1]], hsapiensGene = hsapiens)
rm(hsapiens, list, raw)


# Best BLASTP Hits ====
# Get the highest match for each peptide:
blastp <- wormbaseFile("best_blast_hits") %>%
    readr::read_csv(., col_names = FALSE) %>%
    dplyr::select(X1, X4, X5) %>%
    dplyr::rename(wormpep = X1, peptide = X4, eValue = X5) %>%
    dplyr::filter(grepl("^ENSEMBL", peptide)) %>%
    dplyr::mutate(peptide = stringr::str_sub(peptide, 9)) %>%
    dplyr::arrange(wormpep, eValue) %>%
    dplyr::distinct(.)

# Wormpep IDs are used for BLASTP matching:
if (!file.exists("data-raw/wormbase/wormpep.tar.gz")) {
    dir <- "ftp://ftp.wormbase.org/pub/wormbase/releases/current-production-release/species/c_elegans/PRJNA13758/"
    file <- RCurl::getURL(dir, dirlistonly = TRUE) %>%
        stringr::str_split(., "\n") %>%
        .[[1]] %>%
        stringr::str_subset(., "wormpep_package") %>%
        as.character(.) %>%
        paste0(dir, .)
    utils::download.file(file, "data-raw/wormbase/wormpep.tar.gz")
}
file <- list.files(path = "data-raw/wormbase",
                   pattern = "wormpep.table",
                   full.names = TRUE)
if (length(file) == 0) {
    utils::untar("data-raw/wormbase/wormpep.tar.gz",
                 exdir = "data-raw/wormbase",
                 files = "wormpep.table*")
    file <- list.files(path = "data-raw/wormbase",
                       pattern = "wormpep.table",
                       full.names = TRUE)
}
wormpep <- readr::read_lines(file) %>%
    stringr::str_split(., "\n") %>%
    parallel::mclapply(., function(x) {
        gsub("^.*\t(CE[0-9]+\tWBGene[0-9]+).*$", "\\1", x) %>%
            stringr::str_split(., "\t") %>% .[[1]]
    }) %>%
    do.call(rbind, .) %>%
    tibble::as_tibble(.) %>%
    magrittr::set_names(c("wormpep", "gene"))

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
wormbase[["blastp"]] <- dplyr::left_join(blastp, blastpHsapiens, by = "peptide")
rm(blastp, blastpHsapiens, file, mart, options)


# External Identifiers ====
wormbase[["external"]] <- wormbaseRestGeneExternal(wormbase$gene$gene[1:10])


# Save ====
save(wormbase, file = "data-raw/wormbase.rda")
