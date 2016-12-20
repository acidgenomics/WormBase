#' WormBase RESTful RNAi gene ontology query
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
#' restGeneOntology("WBGene00000001")
restGeneOntology <- function(identifier) {
    lapply(seq_along(identifier), function(a) {
        b <- identifier[[a]]
        rest <- paste0("widget/gene/", b, "/gene_ontology") %>%
            rest %>% .$fields %>% .$gene_ontology %>% .$data
        parallel::mclapply(seq_along(rest), function(c) {
            d <- rest[[c]]
            lapply(seq_along(d), function(e) {
                paste(identifier = d[[e]]$term_description$id,
                      name = d[[e]]$term_description$label,
                      sep = "~")
            }) %>% unique %>% toString
        }) %>% magrittr::set_names(names(rest)) %>%
            tibble::as_tibble(.) %>%
            dplyr::mutate_(.dots = magrittr::set_names(list(~b), "gene"))
    }) %>% dplyr::bind_rows(.) %>% setNamesCamel
}
