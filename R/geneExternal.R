#' Gene External RESTful Query
#'
#' @importFrom basejump toStringUnique
#' @importFrom BiocParallel bplapply
#' @importFrom dplyr bind_rows
#'
#' @param gene Gene identifier.
#'
#' @return [tibble].
#' @export
#'
#' @examples
#' geneExternal(c("WBGene00000912", "WBGene00004804")) %>% glimpse()
geneExternal <- function(gene) {
    gene <- .uniqueIdentifier(gene)
    .assertAllAreGenes(gene)
    list <- lapply(gene, function(id) {
        query <- paste(
            "widget",
            "gene",
            id,
            "external_links",
            sep = "/"
        )
        data <- rest(query) %>%
            .[["fields"]] %>%
            .[["xrefs"]] %>%
            .[["data"]]
        if (is.null(data)) {
            return(NULL)
        }
        xrefs <- bplapply(data, function(x) {
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
    if (!length(list)) {
        return(NULL)
    }
    list %>%
        bind_rows() %>%
        set_names(tolower(names(.))) %>%
        .[, unique(c("gene", sort(colnames(.))))]
}
