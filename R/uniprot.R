#' UniProt web service query
#'
#' @importFrom dplyr bind_rows group_by_ rename_ select_
#' @importFrom UniProt.ws select UniProt.ws
#' @param identifier WormBase gene identifier
#' @return tibble
uniprot <- function(identifier) {
    identifier <- identifier %>% stats::na.omit(.) %>% unique %>% sort
    database <- UniProt.ws::UniProt.ws(taxId = 6239)  # NCBI C. elegans
    query <- suppressMessages(
        UniProt.ws::select(database,
                           keytype = "WORMBASE",
                           keys = identifier,
                           columns = c("EGGNOG",
                                       "EXISTENCE",
                                       "FAMILIES",
                                       "GO",
                                       "KEYWORDS",
                                       "REVIEWED",
                                       "SCORE",
                                       "UNIPROTKB",
                                       "WORMBASE"))
    ) %>%
        setNamesCamel %>%
        dplyr::select_(.dots = c("wormbase",
                                 setdiff(sort(names(.)), "wormbase"))) %>%
        dplyr::group_by_(.dots = "wormbase") %>%
        dplyr::rename_(.dots = c("gene" = "wormbase",
                                 "uniprotExistence" = "existence",
                                 "uniprotFamilies" = "families",
                                 "uniprotGeneOntology" = "go",
                                 "uniprotKeywords" = "keywords",
                                 "uniprotReviewed" = "reviewed",
                                 "uniprotScore" = "score"))
    query2 <- suppressMessages(
        UniProt.ws::select(database,
                           keytype = "UNIPROTKB",
                           keys = query1$uniprotkb,
                           columns = c("EGGNOG"))
    ) %>%
        setNamesCamel %>%
        dplyr::filter(grepl("^KOG", eggnog)) %>%
        dplyr::group_by_(.dots = "uniprotkb") %>%
        dplyr::arrange_(.dots = c("uniprotkb",
                                  "eggnog")) %>%
        dplyr::slice(1)
    query3 <- eggnog(query2$eggnog)
    dplyr::left_join(query1, query2, by = "uniprotkb") %>%
        dplyr::left_join(query3, by = "eggnog")
}
