#' External Identifiers
#'
#' @inheritParams params
#'
#' @return `tbl_df`.
#' @export
#'
#' @examples
#' x <- externalIDs(
#'     genes = c("WBGene00000912", "WBGene00004804"),
#'     progress = FALSE
#' )
#' glimpse(x)
externalIDs <- function(genes, progress = TRUE) {
    .assertAllAreGenes(genes)
    assert_is_a_bool(progress)
    # Allow the user to disable progress bar.
    if (!isTRUE(progress)) {
        pblapply <- lapply
    }

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
            mutate(geneID = gene)
    })
    list <- Filter(Negate(is.null), list)
    if (!length(list)) {
        return(NULL)
    }
    list %>%
        bind_rows() %>%
        camel() %>%
        .[, unique(c("geneID", sort(colnames(.))))]
}
