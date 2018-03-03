#' Gene Ontology RESTful Query
#'
#' @importFrom basejump camel
#' @importFrom BiocParallel bplapply
#' @importFrom dplyr bind_rows mutate
#' @importFrom tibble as_tibble tibble
#'
#' @param gene Gene identifier.
#'
#' @return [tibble].
#' @export
#'
#' @examples
#' geneOntology(c("WBGene00000912", "WBGene00004804")) %>% glimpse()
geneOntology <- function(gene) {
    gene <- .uniqueIdentifier(gene)
    .assertAllAreGenes(gene)
    list <- lapply(gene, function(id) {
        query <- paste(
            "widget",
            "gene",
            id,
            "gene_ontology",
            sep = "/"
        )
        data <- rest(query) %>%
            .[["fields"]] %>%
            .[["gene_ontology"]] %>%
            .[["data"]]
        if (is.null(data)) {
            return(NULL)
        }
        goTerms <- bplapply(seq_along(data), function(a) {
            lapply(seq_along(data[[a]]), function(b) {
                gene <- data[[a]][[b]][["term_description"]][["id"]]
                name <- data[[a]][[b]][["term_description"]][["label"]]
                paste(gene, name, sep = "~")
            }) %>%
                unlist() %>%
                unique() %>%
                sort()
        })
        names(goTerms) <- camel(names(data))
        tibble(
            "gene" = id,
            "biologicalProcess" = list(goTerms[["biologicalProcess"]]),
            "cellularComponent" = list(goTerms[["cellularComponent"]]),
            "molecularFunction" = list(goTerms[["molecularFunction"]])
        )
    })
    df <- bind_rows(list)
    if (!nrow(df)) {
        return(NULL)
    }
    df[, unique(c("gene", sort(colnames(df))))]
}
