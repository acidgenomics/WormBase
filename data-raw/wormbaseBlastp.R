# Get the highest match for each peptide:
blastp <- wormbaseAnnotationFile("best_blast_hits") %>%
    read_csv(col_names = FALSE) %>%
    select(X1, X4, X5) %>%
    rename(wormpep = X1,
           peptide = X4,
           eValue = X5) %>%
    filter(grepl("^ENSEMBL", peptide)) %>%
    mutate(peptide = str_sub(peptide, 9)) %>%
    arrange(wormpep, eValue) %>%
    distinct

# Wormpep IDs are used for BLASTP matching:
fileLocal <- "data-raw/wormbase/wormpep.tsv.gz"
if (!file.exists(fileLocal)) {
    dir <- "ftp://ftp.wormbase.org/pub/wormbase/releases/current-production-release/species/c_elegans/PRJNA13758/"
    fileRemote <- RCurl::getURL(dir, dirlistonly = TRUE) %>%
        str_split("\n") %>%
        .[[1]] %>%
        str_subset("wormpep_package") %>%
        as.character %>%
        paste0(dir, .)
    download.file(fileRemote, fileLocal)
    untar(fileLocal,
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
wormpep <- read_lines(fileLocal) %>%
    str_split("\n") %>%
    mclapply(function(x) {
        gsub("^.*\t(CE[0-9]+\tWBGene[0-9]+).*$", "\\1", x) %>%
            str_split("\t") %>% .[[1]]
    }) %>%
    do.call(rbind, .) %>%
    as_tibble %>%
    setNames(c("wormpep", "gene"))

# Bind the WormBase Gene IDs:
blastp <- left_join(blastp, wormpep, by = "wormpep", all = TRUE) %>%
    arrange(gene, eValue, wormpep) %>%
    distinct(gene, .keep_all = TRUE) %>%
    na.omit %>%
    select(-eValue)

# Map Ensembl Peptide IDs:
library(biomaRt)
mart <- useMart("ensembl", dataset = "hsapiens_gene_ensembl")
options <- listAttributes(mart)
blastpHsapiens <-
    getBM(mart = mart,
          filters = "ensembl_peptide_id",
          values = blastp$peptide,
          attributes = c("ensembl_peptide_id",
                         "ensembl_gene_id",
                         "external_gene_name",
                         "description")) %>%
    rename(peptide = ensembl_peptide_id,
           hsapiensDescription = description,
           hsapiensGene = ensembl_gene_id,
           hsapiensName = external_gene_name)
detach("package:biomaRt", unload = TRUE)

# Final join:
wormbaseBlastp <- left_join(blastp, blastpHsapiens, by = "peptide") %>%
    select(gene, everything())
use_data(wormbaseBlastp, overwrite = TRUE)
rm(blastp,
   blastpHsapiens,
   fileLocal,
   mart,
   options,
   wormpep)
