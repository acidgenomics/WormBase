wormbase <- RCurl::getURL("ftp://ftp.wormbase.org/pub/wormbase/releases/current-production-release/ONTOLOGY/",
                          dirlistonly = TRUE) %>%
    str_extract("WS[0-9]{3}") %>%
    paste0("WormBase ", .)
ensembl <- biomaRt::listMarts(host = "useast.ensembl.org") %>%
    filter(biomart == "ENSEMBL_MART_ENSEMBL") %>%
    select(version) %>%
    .[[1]]
panther <- RCurl::getURL("ftp://ftp.pantherdb.org/sequence_classifications/current_release/PANTHER_Sequence_Classification_files/",
                  dirlistonly = TRUE) %>%
    str_extract("(\\d{2}\\.\\d)") %>%
    paste0("PANTHER ", .)
rstats <- paste0(R.Version()$version.string,
                 " running on ",
                 R.Version()$platform)
build <- list(date = Sys.Date(),
              ensembl = ensembl,
              panther = panther,
              rstats = rstats,
              wormbase = wormbase)
use_data(build, overwrite = TRUE)
