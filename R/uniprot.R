# FIXME Unknown or uninitialised column: 'cogFunctionalCategory'.

#' UniProt Web Service Query
#'
#' @importFrom basejump camel collapseToString
#' @importFrom dplyr left_join rename select
#' @importFrom rlang !! sym
#' @importFrom UniProt.ws UniProt.ws
#'
#' @param identifier WormBase gene identifier.
#'
#' @return [tibble].
#' @export
uniprot <- function(identifier) {
    identifier <- .uniqueIdentifier(identifier)
    # NCBI C. elegans identifier = 6239
    database <- UniProt.ws(taxId = 6239L)
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
    if (nrow(uniprot)) {
        uniprot <- uniprot %>%
            camel() %>%
            select(c("wormbase", setdiff(sort(names(.)), "wormbase")))
        eggnog <- eggnog(uniprot[["eggnog"]])
        # Check and make sure this output is correct
        left_join(uniprot, eggnog, by = "eggnog") %>%
            # Sort priority to put higher quality UniProtKB identifiers first
            .[order(.[["wormbase"]],
                    .[["cogFunctionalDescription"]],
                    -xtfrm(.[["score"]])), ] %>%
            rename(gene = !!sym("wormbase"),
                   uniprotExistence = !!sym("existence"),
                   uniprotFamilies = !!sym("families"),
                   uniprotGeneOntology = !!sym("go"),
                   uniprotKeywords = !!sym("keywords"),
                   uniprotReviewed = !!sym("reviewed"),
                   uniprotScore = !!sym("score")) %>%
            select(sort(names(.))) %>%
            group_by(!!sym("gene")) %>%
            collapseToString()
    }
}
