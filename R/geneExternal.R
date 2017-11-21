#' WormBase RESTful Gene External Query
#'
#' @importFrom basejump toStringUnique
#' @importFrom dplyr bind_rows
#' @importFrom parallel mclapply
#'
#' @param identifier Gene identifier.
#'
#' @return JSON content tibble.
#' @export
#'
#' @examples
#' geneExternal("WBGene00000001") %>% glimpse()
geneExternal <- function(identifier) {
    identifier <- uniqueIdentifier(identifier)
    list <- lapply(seq_along(identifier), function(a) {
        if (!grepl(pattern = "^WBGene[0-9]{8}$", x = identifier[[a]])) {
            stop("Invalid gene identifier")
        }
        rest <- file.path(
            "widget",
            "gene",
            identifier[[a]],
            "external_links") %>%
            rest() %>%
            .[["fields"]] %>%
            .[["xrefs"]] %>%
            .[["data"]]
        xrefs <- mclapply(seq_along(rest), function(b) {
            rest[[b]] %>%
                .[[1L]] %>%
                .[[1L]] %>%
                unlist() %>%
                toStringUnique()
        })
        names(xrefs) <- names(rest)
        xrefs %>%
            as_tibble() %>%
            mutate(gene = identifier[[a]])
    })
    df <- bind_rows(list)
    names(df) <- tolower(names(df))
    df
}
