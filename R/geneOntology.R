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
        b <- identifier[[a]]
        if (!grepl("^WBGene[0-9]{8}$", b)) {
            stop("Invalid gene identifier.")
        }
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
    }) %>% dplyr::bind_rows(.) %>%
        dplyr::rename_(.dots = c("wormbaseGeneOntologyBiologicalProcess" =
                                     "Biological_process",
                                 "wormbaseGeneOntologyCellularComponent" =
                                     "Cellular_component",
                                 "wormbaseGeneOntologyMolecularFunction" =
                                     "Molecular_function"))
}
