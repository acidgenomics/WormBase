# FIXME Need to improve the appearance of GO terms

#' UniProt Web Service Query
#'
#' @importFrom basejump camel collapseToString
#' @importFrom dplyr left_join pull rename
#' @importFrom rlang !! sym
#' @importFrom UniProt.ws UniProt.ws
#'
#' @keywords internal
#'
#' @param identifier WormBase gene identifier.
#'
#' @return [tibble].
#' @export
#'
#' @examples
#' # daf-2
#' uniprot("WBGene00000898") %>%
#'     glimpse()
uniprot <- function(identifier) {
    identifier <- .uniqueIdentifier(identifier)

    # NCBI C. elegans identifier = 6239
    database <- UniProt.ws::UniProt.ws(taxId = 6239L)
    # Explicitly call the `AnnotationDbi::select()`` generic here, avoiding
    # collision with `dplyr::select()`.
    uniprot <- UniProt.ws::select(
        database,
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
    if (!nrow(uniprot)) {
        return(NULL)
    }

    uniprot <- uniprot %>%
        camel() %>%
        .[, c("wormbase", setdiff(sort(names(.)), "wormbase")), ]
    eggnog <- pull(uniprot, "eggnog") %>%
        eggnog()

    left_join(uniprot, eggnog, by = "eggnog") %>%
        # Sort priority to put higher quality UniProtKB identifiers first
        .[order(.[["wormbase"]],
                -xtfrm(.[["score"]]),
                .[["reviewed"]],
                .[["cogFunctionalDescription"]]), ] %>%
        rename(
            gene = .data[["wormbase"]],
            uniprotExistence = .data[["existence"]],
            uniprotFamilies = .data[["families"]],
            uniprotGeneOntology = .data[["go"]],
            uniprotKeywords = .data[["keywords"]],
            uniprotReviewed = .data[["reviewed"]],
            uniprotScore = .data[["score"]]
        ) %>%
        group_by(!!sym("gene")) %>%
        collapseToString(sort = FALSE, unique = TRUE)
}
