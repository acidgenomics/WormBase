#' WormBase RESTful gene external query
#'
#' @author Michael Steinbaugh
#'
#' @param identifier Gene identifier
#'
#' @return JSON content tibble
#' @export
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
        }) %>% setNames(names(rest)) %>%
            as_tibble %>%
            mutate_(.dots = setNames(list(
                ~identifier[[a]]), "gene"))
    }) %>% bind_rows %>%
        setNames(tolower(names(.)))
}
