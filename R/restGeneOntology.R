#' WormBase RESTful RNAi gene ontology query
#'
#' @import dplyr
#' @import magrittr
#'
#' @param gene Gene identifier
#'
#' @return JSON content tibble
#' @export
#'
#' @examples
#' restGeneOntology("WBGene00000001")
restGeneOntology <- function(gene) {
    lapply(seq_along(gene), function(w) {
        x <- gene[[w]]
        rest <- rest(paste0("widget/gene/", x, "/gene_ontology")) %>%
            .$fields %>% .$gene_ontology %>% .$data
        lapply(seq_along(rest), function(x) {
            y <- rest[[x]]
            lapply(seq_along(y), function(z) {
                paste(identifier = y[[z]]$term_description$id,
                      name = y[[z]]$term_description$label,
                      sep = "~")
            }) %>% unique %>% toString
        }) %>% magrittr::set_names(c("biologicalProcess",
                                     "cellularComponent",
                                     "molecularFunction")) %>%
            tibble::as_tibble(.)
    }) %>% magrittr::set_names(gene) %>%
        dplyr::bind_rows(.) %>%
        dplyr::mutate(gene = gene)
}
