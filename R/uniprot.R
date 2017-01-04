#' UniProt web service query
#'
#' @importFrom dplyr bind_rows group_by_ rename_ select_
#' @importFrom parallel mclapply
#' @importFrom pbmcapply pbmclapply
#' @importFrom UniProt.ws select UniProt.ws
#'
#' @param identifier WormBase gene identifier
#' @return tibble
#'
#' @export
uniprot <- function(identifier) {
    identifier <- identifier %>% stats::na.omit(.) %>% unique %>% sort
    if (length(identifier) < 100) {
        lapply <- parallel::mclapply
    } else {
        lapply <- pbmcapply::pbmclapply
    }
    database <- UniProt.ws::UniProt.ws(taxId = 6239)  # NCBI C. elegans
    result <- lapply(seq_along(identifier), function(a) {
        key <- geneExternal(identifier[a])
        if (!is.null(key[["uniprot"]])) {
            key <- key[, "uniprot"] %>% .[[1]] %>%
                strsplit(", ") %>% .[[1]]
            UniProt.ws::select(database, keytype = "UNIPROTKB", keys = key,
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
                setNamesCamel %>%
                dplyr::group_by_(.dots = "uniprotkb") %>%
                collapse %>%
                .[order(-xtfrm(.$score), .$reviewed, .$uniprotkb), ] %>%
                .[1, ]
        }
    }) %>% dplyr::bind_rows(.)
    if (nrow(result)) {
        result <- result %>%
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
                                     setdiff(sort(names(.)), "gene")))
    }
    return(result)
}
