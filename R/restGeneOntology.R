#' WormBase RESTful RNAi gene ontology query
#'
#' @import dplyr
#' @import magrittr
#' @import parallel
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
        # Parallelize the recursive loops for each REST query:
        parallel::mclapply(seq_along(rest), function(x) {
            y <- rest[[x]]
            lapply(seq_along(y), function(z) {
                paste(identifier = y[[z]]$term_description$id,
                      name = y[[z]]$term_description$label,
                      sep = "~")
            }) %>% unique %>% toString
        }) %>% magrittr::set_names(names(rest)) %>%
            tibble::as_tibble(.) %>%
            dplyr::mutate_(.dots = magrittr::set_names(list(~x), "gene"))
    }) %>% dplyr::bind_rows(.)
}
