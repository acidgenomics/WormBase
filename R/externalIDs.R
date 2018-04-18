#' External Identifiers
#'
#' @family REST API Functions
#'
#' @param gene Gene identifier.
#'
#' @return `tbl_df`.
#' @export
#'
#' @examples
#' externalIDs(c("WBGene00000912", "WBGene00004804")) %>% glimpse()
externalIDs <- function(gene) {
    .assertAllAreGenes(gene)
    list <- lapply(gene, function(id) {
        query <- paste(
            "widget",
            "gene",
            id,
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
        xrefs <- mclapply(data, function(x) {
            x %>%
                .[[1L]] %>%
                .[[1L]] %>%
                unlist() %>%
                unique() %>%
                sort()
        })
        lapply(xrefs, list) %>%
            as_tibble() %>%
            mutate(gene = id)
    })
    list <- Filter(Negate(is.null), list)
    if (!length(list)) {
        return(NULL)
    }
    list %>%
        bind_rows() %>%
        set_colnames(tolower(names(.))) %>%
        .[, unique(c("gene", sort(colnames(.))))]
}
