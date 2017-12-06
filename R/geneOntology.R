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
#' geneOntology("WBGene00004804") %>% glimpse()
geneOntology <- function(identifier) {
    identifier <- .uniqueIdentifier(identifier)
    list <- lapply(seq_along(identifier), function(a) {
        if (!grepl("^WBGene[0-9]{8}$", identifier[[a]])) {
            warning(paste(
                "Invalid identifier", identifier[[a]]
            ), call. = FALSE)
            return(NULL)
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
        if (is.null(rest)) return(NULL)
        goTerms <- mclapply(seq_along(rest), function(b) {
            lapply(seq_along(rest[[b]]), function(c) {
                identifier <- rest[[b]][[c]][["term_description"]][["id"]]
                name <- rest[[b]][[c]][["term_description"]][["label"]]
                paste(identifier, name, sep = "~")
            }) %>%
                unique() %>%
                toString()
        })
        names(goTerms) <- camel(names(rest))
        goTerms %>%
            as_tibble() %>%
            mutate(gene = identifier[[a]])
    })
    df <- bind_rows(list)
    if (!nrow(df)) return(NULL)
    df[, unique(c("gene", sort(colnames(df))))]
}
