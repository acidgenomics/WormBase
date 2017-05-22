#' UniProt web service query
#'
#' @param identifier WormBase gene identifier.
#'
#' @return Tibble.
#' @export
uniprot <- function(identifier) {
    # [fix] Unknown or uninitialised column: 'cogFunctionalCategory'.
    identifier <- uniqueIdentifier(identifier)
    # NCBI C. elegans identifier = 6239
    database <- UniProt.ws(taxId = 6239)
    uniprot <-  UniProt.ws::select(
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
            camel %>%
            select(!!!syms(c(
                "wormbase", setdiff(sort(names(.)), "wormbase"))))
        eggnog <- eggnog(uniprot$eggnog)
        # Check and make sure this output is correct
        left_join(uniprot, eggnog, by = "eggnog") %>%
            # Sort priority to put higher quality UniProtKB identifiers first
            # [fix] rework using dplyr method -- top_n?
            .[order(.$wormbase,
                    .$cogFunctionalDescription,
                    -xtfrm(.$score)), ] %>%
            # [fix] check that this works
            rename(gene = !!sym("wormbase"),
                   uniprotExistence = !!sym("existence"),
                   uniprotFamilies = !!sym("families"),
                   uniprotGeneOntology = !!sym("go"),
                   uniprotKeywords = !!sym("keywords"),
                   uniprotReviewed = !!sym("reviewed"),
                   uniprotScore = !!sym("score")) %>%
            # [fix] this may error out
            select(sort(names(.))) %>%
            group_by(!!sym("gene")) %>%
            summarizeRows
    }
}
