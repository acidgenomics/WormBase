#' UniProt web service query
#'
#' @export
#' @importFrom dplyr bind_rows group_by_ rename_ select_
#' @importFrom tidyr nest
#' @importFrom UniProt.ws select UniProt.ws
#' @param identifier WormBase gene identifier
#' @return tibble
uniprot <- function(identifier) {
    identifier <- uniqueIdentifier(identifier)
    database <- UniProt.ws::UniProt.ws(taxId = 6239)  # NCBI C. elegans
    uniprot <-  UniProt.ws::select(database,
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
    if (nrow(uniprot)) {
        uniprot <- uniprot %>%
            setNamesCamel %>%
            dplyr::select_(.dots = c("wormbase",
                                     setdiff(sort(names(.)), "wormbase")))
        eggnog <- eggnog(uniprot$eggnog)
        x <- dplyr::left_join(uniprot, eggnog, by = "eggnog") %>%
            # Sort priority to put higher quality UniProtKB identifiers first:
            .[order(.$wormbase,
                    .$cogFunctionalCategory,
                    -xtfrm(.$score)), ] %>%
            dplyr::rename_(.dots = c("gene" = "wormbase",
                                     "uniprotExistence" = "existence",
                                     "uniprotFamilies" = "families",
                                     "uniprotGeneOntology" = "go",
                                     "uniprotKeywords" = "keywords",
                                     "uniprotReviewed" = "reviewed",
                                     "uniprotScore" = "score")) %>%
            dplyr::select_(.dots = sort(names(.))) %>%
            dplyr::group_by_(.dots = "gene") %>%
            toStringSummarize
    }
}
