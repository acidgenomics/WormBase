#' Gene List Report
#'
#' @importFrom basejump annotable
#' @importFrom dplyr arrange everything left_join mutate rename select
#' @importFrom rlang !!! syms
#' @importFrom tibble as_tibble remove_rownames
#'
#' @param identifier Gene identifier.
#' @param format Identifier format.
#'
#' @return [tibble].
#' @export
#'
#' @examples
#' geneReport("daf-2", format = "name") %>% glimpse()
geneReport <- function(identifier, format = "gene") {
    identifier <- .uniqueIdentifier(identifier)
    gene <- gene(
        identifier,
        format = format,
        select = c(defaultCol,
                   "class",
                   # Ortholog ====
                   "ortholog",
                   # TODO Need to add the blastp matching back with biomaRt
                   # Description ====
                   "descriptionConcise",
                   # WormBase Additional ====
                   "rnaiPhenotype",
                   # Gene Ontology ====
                   "pantherSubfamilyName",
                   "pantherGoMF",
                   "pantherGoBP",
                   "pantherGoCC",
                   "pantherClass",
                   "pantherPathway"))
    if (is.null(gene)) return(NULL)

    annotable <- annotable("Caenorhabditis elegans") %>%
        remove_rownames() %>%
        as_tibble() %>%
        mutate(symbol = NULL) %>%
        rename(ensemblDescription = .data[["description"]])
    report <- left_join(gene, annotable, by = c("gene" = "ensgene"))

    genes <- pull(report, "gene")

    # Gene Ontology
    geneOntology <- geneOntology(genes)
    if (nrow(geneOntology)) {
        report <- left_join(report, geneOntology, by = "gene")
    }

    # Uniprot
    uniprot <- uniprot(genes)
    if (nrow(uniprot)) {
        report <- left_join(report, uniprot, by = "gene")
    }

    report %>%
        select(defaultCol, everything()) %>%
        arrange(!!!syms(defaultCol))
}
