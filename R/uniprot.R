#' UniProt web service query
#'
#' @param identifier WormBase gene identifier
#'
#' @return tibble
#' @export
uniprot <- function(identifier) {
    identifier <- uniqueIdentifier(identifier)
    database <- UniProt.ws(taxId = 6239)  # NCBI C. elegans
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
            setNamesCamel %>%
            select_(.dots = c("wormbase",
                              setdiff(sort(names(.)), "wormbase")))
        eggnog <- eggnog(uniprot$eggnog)
        x <- left_join(uniprot, eggnog, by = "eggnog") %>%
            # Sort priority to put higher quality UniProtKB identifiers first:
            .[order(.$wormbase,
                    .$cogFunctionalDescription,
                    -xtfrm(.$score)), ] %>%
            rename_(.dots = c("gene" = "wormbase",
                              "uniprotExistence" = "existence",
                              "uniprotFamilies" = "families",
                              "uniprotGeneOntology" = "go",
                              "uniprotKeywords" = "keywords",
                              "uniprotReviewed" = "reviewed",
                              "uniprotScore" = "score")) %>%
            select_(.dots = sort(names(.))) %>%
            group_by_(.dots = "gene") %>%
            toStringSummarize
    }
}
