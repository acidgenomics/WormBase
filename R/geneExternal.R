#' WormBase RESTful gene external query
#'
#' @import dplyr
#' @import magrittr
#' @import parallel
#' @import tibble
#'
#' @param identifier Gene identifier
#'
#' @return JSON content tibble
#' @export
#'
#' @examples
#' geneExternal("WBGene00000001")
geneExternal <- function(identifier) {
    lapply(seq_along(identifier), function(a) {
        b <- identifier[[a]]
        rest <- paste0("widget/gene/", b, "/external_links") %>%
            rest %>% .$fields %>% .$xrefs %>% .$data
        parallel::mclapply(seq_along(rest), function(c) {
            rest[[c]] %>% .[[1]] %>% .[[1]] %>%
                unlist %>% toStringUnique
        }) %>% magrittr::set_names(names(rest)) %>%
            tibble::as_tibble(.) %>%
            dplyr::mutate_(.dots = magrittr::set_names(list(~b), "gene"))
    }) %>% dplyr::bind_rows(.) %>%
        magrittr::set_names(tolower(names(.)))
}
