fileLocal <- "data-raw/wormbase/rnai_phenotypes.tsv.gz"
if (!file.exists(fileLocal)) {
    dir <- "ftp://ftp.wormbase.org/pub/wormbase/releases/current-production-release/ONTOLOGY/"
    fileRemote <- RCurl::getURL(dir, dirlistonly = TRUE) %>%
        str_split("\n") %>%
        .[[1]] %>%
        str_subset("rnai_phenotypes_quick") %>%
        paste0(dir, .)
    fileLocal <- "data-raw/wormbase/rnai_phenotypes.tsv"
    download.file(fileRemote, fileLocal)
    rm(dir, fileRemote)
    R.utils::gzip(fileLocal, overwrite = TRUE)
    fileLocal <- paste0(fileLocal, ".gz")
}
wormbaseRnaiPhenotype <-
    read_tsv(fileLocal,
             col_names = c("gene",
                           "sequence",
                           "rnaiPhenotype")) %>%
    select(-sequence)
use_data(wormbaseRnaiPhenotype, overwrite = TRUE)
rm(fileLocal)
