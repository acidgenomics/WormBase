#' UniProt web service query
#'
#' @importFrom dplyr bind_rows group_by_ rename_ select_
#' @importFrom parallel mclapply
#' @importFrom pbmcapply pbmclapply
#' @importFrom UniProt.ws select UniProt.ws
#'
#' @param identifier UniProtKB identifier
#' @return tibble
#'
#' @export
uniprot <- function(identifier) {
    identifier <- identifier %>% stats::na.omit(.) %>% unique %>% sort
    database <- UniProt.ws::UniProt.ws(taxId = 6239)  # NCBI C. elegans
    query1 <-  UniProt.ws::select(database,
                                  keytype = "UNIPROTKB",
                                  keys = identifier,
                                  columns = c("EXISTENCE",
                                              "FAMILIES",
                                              "GO",
                                              "KEYWORDS",
                                              "REACTOME",
                                              "REVIEWED",
                                              "SCORE",
                                              "WORMBASE")) %>%
        setNamesCamel %>%
        dplyr::select_(.dots = c("wormbase",
                                 setdiff(sort(names(.)), "wormbase"))) %>%
        # Group by gene and select the highest confidence UniProt annotation:
        dplyr::filter(!is.na(wormbase)) %>%
        dplyr::group_by_(.dots = "wormbase") %>%
        .[order(.$wormbase,
                -xtfrm(.$score),
                .$reviewed,
                .$uniprotkb), ] %>%
        dplyr::slice(1) %>%
        dplyr::rename_(.dots = c("gene" = "wormbase",
                                 "uniprotExistence" = "existence",
                                 "uniprotFamilies" = "families",
                                 "uniprotGeneOntology" = "go",
                                 "uniprotKeywords" = "keywords",
                                 "uniprotReviewed" = "reviewed",
                                 "uniprotScore" = "score"))
}
