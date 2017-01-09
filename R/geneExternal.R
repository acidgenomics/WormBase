#' WormBase RESTful gene external query
#' @export
#' @importFrom dplyr bind_rows mutate_
#' @importFrom magrittr set_names
#' @importFrom parallel mclapply
#' @importFrom tibble as_tibble
#' @param identifier Gene identifier
#' @return JSON content tibble
geneExternal <- function(identifier) {
    identifier <- uniqueIdentifier(identifier)
    lapply(seq_along(identifier), function(a) {
        if (!grepl("^WBGene[0-9]{8}$", identifier[[a]])) {
            stop("Invalid gene identifier.")
        }
        rest <- paste0("widget/gene/", identifier[[a]], "/external_links") %>%
            rest %>% .$fields %>% .$xrefs %>% .$data
        parallel::mclapply(seq_along(rest), function(b) {
            rest[[b]] %>% .[[1]] %>% .[[1]] %>%
                unlist %>% toStringUnique
        }) %>% magrittr::set_names(names(rest)) %>%
            tibble::as_tibble(.) %>%
            dplyr::mutate_(.dots = magrittr::set_names(list(~identifier[[a]]), "gene"))
    }) %>% dplyr::bind_rows(.) %>%
        magrittr::set_names(tolower(names(.)))
}
