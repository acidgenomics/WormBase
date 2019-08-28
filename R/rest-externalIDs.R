#' External identifiers
#'
#' @note Updated 2019-08-28.
#' @export
#'
#' @inheritParams params
#'
#' @return `DataFrame`.
#'
#' @examples
#' ## WormBase REST API must be accessible.
#' tryCatch(
#'     expr = externalIDs(c("WBGene00000912", "WBGene00004804")),
#'     error = function(e) e
#' )
externalIDs <- function(genes, progress = FALSE) {
    assert(.allAreGenes(genes))
    pblapply <- .pblapply(progress = progress)
    list <- lapply(genes, function(gene) {
        query <- paste(
            "widget",
            "gene",
            gene,
            "external_links",
            sep = "/"
        )
        data <- .rest(query) %>%
            .[["fields"]] %>%
            .[["xrefs"]] %>%
            .[["data"]]
        if (is.null(data)) {
            return(NULL)
        }
        xrefs <- pblapply(data, function(x) {
            x %>%
                .[[1L]] %>%
                .[[1L]] %>%
                unlist() %>%
                unique() %>%
                sort()
        })
        lapply(xrefs, list) %>%
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
