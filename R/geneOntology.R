# FIXME Need to improve the separators here

#' WormBase RESTful RNAi Gene Ontology Query
#'
#' @importFrom basejump camel
#' @importFrom dplyr bind_rows mutate
#' @importFrom parallel mclapply
#' @importFrom tibble as_tibble tibble
#'
#' @param identifier Gene identifier.
#'
#' @return JSON content [tibble].
#' @export
#'
#' @examples
#' geneOntology("WBGene00000001") %>% glimpse()
geneOntology <- function(identifier) {
    identifier <- .uniqueIdentifier(identifier)
    list <- lapply(seq_along(identifier), function(a) {
        if (!grepl("^WBGene[0-9]{8}$", identifier[[a]])) {
            stop("Invalid gene identifier")
        }
        rest <- file.path(
            "widget",
            "gene",
            identifier[[a]],
            "gene_ontology") %>%
            .rest() %>%
            .[["fields"]] %>%
            .[["gene_ontology"]] %>%
            .[["data"]]
        if (!is.null(rest)) {
            goTerms <- mclapply(seq_along(rest), function(b) {
                lapply(seq_along(rest[[b]]), function(c) {
                    identifier <- rest[[b]][[c]][["term_description"]][["id"]]
                    name <- rest[[b]][[c]][["term_description"]][["label"]]
                    paste(identifier, name, sep = "~")
                }) %>%
                    unique() %>%
                    toString()
            })
            names(goTerms) <-
                camel(paste0("wormbaseGeneOntology_", names(rest)))
            goTerms %>%
                as_tibble() %>%
                mutate(gene = identifier[[a]])
        } else {
            tibble()
        }
    })
    bind_rows(list)
}
