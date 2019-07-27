#' Gene Ontology terms
#'
#' @note Updated 2019-07-27.
#' @export
#'
#' @inheritParams params
#'
#' @return `tbl_df`.
#'
#' @examples
#' ## WormBase server must be accessible.
#' if (!is.null(curl::nslookup("wormbase.org"))) {
#'     x <- geneOntology(c("WBGene00000912", "WBGene00004804"))
#'     glimpse(x)
#' }
geneOntology <- function(genes, progress = FALSE) {
    assert(.allAreGenes(genes))
    pblapply <- .pblapply(progress = progress)
    list <- lapply(genes, function(gene) {
        query <- paste(
            "widget",
            "gene",
            gene,
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
        goTerms <- pblapply(data, function(process) {
            lapply(seq_along(process), function(x) {
                id <- process[[x]][["term_description"]][["id"]]
                label <- process[[x]][["term_description"]][["label"]]
                paste(id, label, sep = "~")
            }) %>%
                unlist() %>%
                unique() %>%
                sort()
        })
        lapply(goTerms, list) %>%
            as_tibble() %>%
            mutate(!!sym("geneID") := !!gene)
    })
    list <- Filter(Negate(is.null), list)
    if (!length(list)) {
        return(NULL)
    }
    list %>%
        bind_rows() %>%
        camelCase() %>%
        .[, unique(c("geneID", sort(colnames(.))))]
}
