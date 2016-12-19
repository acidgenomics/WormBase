load_all()
build <-
    c(
        # geneAnnotation ====
        # WormBase Annotation Files
        "wormbaseGene",  # must go first
        "wormbaseBlastp",
        "wormbaseDescription",
        "wormbaseOligo",
        "wormbaseOrtholog",
        "wormbaseRnaiPhenotype",

        # WormBase REST API queries
        "wormbaseGeneExternal",
        "wormbaseGeneOntology",

        # Other databases
        "ensembl",
        "panther",
        # "uniprot",  # in development

        "geneAnnotation",


        # rnaiAnnotation ====
        "worfdb",  # orfeome
        "sourcebioscience",  # ahringer
        "rnaiAnnotation"
    )

for (a in 1:length(build)) {
    if (!file.exists(paste0("data/", build[a], ".rda"))) {
        source(paste0("data-raw/", build[a], ".R"))
    } else {
        load(paste0("data/", build[a], ".rda"))
    }
}


# Build information ====
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
