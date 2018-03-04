#' Gene Ontology
#'
#' @family REST API Functions
#'
#' @importFrom basejump camel
#' @importFrom BiocParallel bplapply
#' @importFrom dplyr bind_rows mutate
#' @importFrom tibble as_tibble tibble
#'
#' @inheritParams general
#'
#' @return Gene [tibble].
#' @export
#'
#' @examples
#' geneOntology(c("WBGene00000912", "WBGene00004804")) %>% glimpse()
geneOntology <- function(gene) {
    .assertAllAreGenes(gene)
    list <- lapply(gene, function(id) {
        query <- paste(
            "widget",
            "gene",
            id,
            "gene_ontology",
            sep = "/"
        )
        data <- .rest(query) %>%
            .[["fields"]] %>%
            .[["gene_ontology"]] %>%
            .[["data"]]
        if (is.null(data)) {
            return(NULL)
        }
        goTerms <- bplapply(data, function(process) {
            lapply(seq_along(process), function(x) {
                gene <- process[[x]][["term_description"]][["id"]]
                name <- process[[x]][["term_description"]][["label"]]
                paste(gene, name, sep = "~")
            }) %>%
                unlist() %>%
                unique() %>%
                sort()
        })
        lapply(goTerms, list) %>%
            as_tibble() %>%
            mutate(gene = id)
    })
    if (!length(list)) {
        return(NULL)
    }
    list %>%
        bind_rows() %>%
        camel() %>%
        .[, unique(c("gene", sort(colnames(.))))]
}
