#' UniProt web service query
#'
#' @importFrom dplyr bind_rows rename_ select_
#' @importFrom parallel mclapply
#' @importFrom pbmcapply pbmclapply
#' @importFrom UniProt.ws select UniProt.ws
#'
#' @param query WormBase identifier
#' @return tibble
#'
#' @export
uniprot <- function(query) {
    query <- query %>% stats::na.omit(.) %>% unique %>% sort
    if (length(query) < 100) {
        lapply <- parallel::mclapply
    } else {
        lapply <- pbmcapply::pbmclapply
    }
    database <- UniProt.ws::UniProt.ws(taxId = 6239)  # NCBI C. elegans
    lapply(seq_along(query), function(a) {
        key <- geneExternal(query[a]) %>%
            .[, "uniprot"] %>% .[[1]] %>%
            gsub(",.+$", "", .)
        UniProt.ws::select(database, keytype = "UNIPROTKB", keys = key,
                           #! columns = UniProt.ws::columns(database)) %>%
                           columns = c("CITATION",
                                       "DATABASE(PFAM)",
                                       "EGGNOG",
                                       #! "ENTRY-NAME",
                                       "EXISTENCE",
                                       "FAMILIES",
                                       #! "FEATURES",
                                       #! "GENES",
                                       "GO",
                                       #! "GO-ID",
                                       "HOGENOM",
                                       #! "INTERACTOR",
                                       #! "INTERPRO",
                                       #! "KEGG",
                                       "KEYWORDS",
                                       #! "LAST-MODIFIED",
                                       "ORTHODB",
                                       #! "PATHWAY",
                                       #! "PROTEIN-NAMES",
                                       "REACTOME",
                                       "REVIEWED",
                                       "SCORE",
                                       "WORMBASE")) %>%
            collapse
    }) %>% dplyr::bind_rows(.) %>% setNamesCamel %>%
        dplyr::rename_(.dots = c("gene" = "wormbase",
                                 "pfam" = "databasePfam",
                                 "uniprotCitation" = "citation",
                                 "uniprotExistence" = "existence",
                                 "uniprotFamilies" = "families",
                                 "uniprotGeneOntology" = "go",
                                 "uniprotKeywords" = "keywords",
                                 "uniprotReviewed" = "reviewed",
                                 "uniprotScore" = "score")) %>%
        dplyr::select_(.dots = c("gene",
                                 setdiff(sort(names(.)),
                                         c("gene", "uniprotkb"))))
}
