#' WormBase RESTful RNAi gene ontology query
#'
#' @importFrom dplyr bind_rows mutate_ rename_
#' @importFrom magrittr set_names
#' @importFrom parallel mclapply
#' @importFrom tibble as_tibble
#'
#' @param identifier Gene identifier
#'
#' @return JSON content tibble
#' @export
#'
#' @examples
#' geneOntology("WBGene00000001")
geneOntology <- function(identifier) {
    lapply(seq_along(identifier), function(a) {
        if (!grepl("^WBGene[0-9]{8}$", identifier[[a]])) {
            stop("Invalid gene identifier.")
        }
        rest <- paste0("widget/gene/", identifier[[a]], "/gene_ontology") %>%
            rest %>% .$fields %>% .$gene_ontology %>% .$data
        parallel::mclapply(seq_along(rest), function(b) {
            lapply(seq_along(rest[[b]]), function(c) {
                paste(identifier = rest[[b]][[c]]$term_description$id,
                      name = rest[[b]][[c]]$term_description$label,
                      sep = "~")
            }) %>% unique %>% toString
        }) %>% magrittr::set_names(camel(paste0("wormbaseGeneOntology_", names(rest)))) %>%
            tibble::as_tibble(.) %>%
            dplyr::mutate_(.dots = magrittr::set_names(list(~identifier[[a]]), "gene"))
    }) %>% dplyr::bind_rows(.)
}
