#' Gene External RESTful Query
#'
#' @importFrom basejump toStringUnique
#' @importFrom dplyr bind_rows
#' @importFrom parallel mclapply
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
        if (is.null(rest)) {
            return(NULL)
        }
        xrefs <- bplapply(data, function(x) {
            x %>%
                .[[1L]] %>%
                .[[1L]] %>%
                unlist() %>%
                toStringUnique()
        })
        xrefs %>%
            as_tibble() %>%
            mutate(gene = id)
    })
    df <- bind_rows(list)
    if (!nrow(df)) {
        return(NULL)
    }
    names(df) <- tolower(names(df))
    df[, unique(c("gene", sort(colnames(df))))]
}
