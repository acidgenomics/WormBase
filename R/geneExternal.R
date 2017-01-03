#' WormBase RESTful gene external query
#'
#' @importFrom dplyr bind_rows mutate_
#' @importFrom magrittr set_names
#' @importFrom parallel mclapply
#' @importFrom tibble as_tibble
#'
#' @param identifier Gene identifier
#' @param all Keep all identifiers (\code{TRUE}/\code{FALSE})
#'
#' @return JSON content tibble
#' @export
#'
#' @examples
#' geneExternal("WBGene00000001")
geneExternal <- function(identifier) {
    identifier <- identifier %>% stats::na.omit(.) %>% unique %>% sort
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
