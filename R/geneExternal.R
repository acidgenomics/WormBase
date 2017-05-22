#' WormBase RESTful gene external query
#'
#' @author Michael Steinbaugh
#'
#' @param identifier Gene identifier.
#'
#' @return JSON content tibble.
#' @export
#'
#' @examples
#' geneExternal("WBGene00000001") %>% t
geneExternal <- function(identifier) {
    identifier <- uniqueIdentifier(identifier)
    lapply(seq_along(identifier), function(a) {
        if (!grepl("^WBGene[0-9]{8}$", identifier[[a]])) {
            stop("Invalid gene identifier.")
        }
        rest <- file.path("widget/gene",
                          identifier[[a]],
                          "external_links") %>%
            rest %>% .$fields %>% .$xrefs %>% .$data
        mclapply(seq_along(rest), function(b) {
            rest[[b]] %>% .[[1]] %>% .[[1]] %>%
                unlist %>% toStringUnique
        }) %>% set_names(names(rest)) %>%
            as_tibble %>%
            # [fix] check that this works
            mutate(gene = identifier[[a]])
    }) %>% bind_rows %>%
        set_names(tolower(names(.)))
}
