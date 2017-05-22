#' WormBase RESTful RNAi gene ontology query
#'
#' @param identifier Gene identifier.
#'
#' @return JSON content tibble.
#' @export
#'
#' @examples
#' geneOntology("WBGene00000001") %>% glimpse
geneOntology <- function(identifier) {
    identifier <- uniqueIdentifier(identifier)
    lapply(seq_along(identifier), function(a) {
        if (!grepl("^WBGene[0-9]{8}$", identifier[[a]])) {
            stop("Invalid gene identifier")
        }
        rest <- file.path("widget",
                          "gene",
                          identifier[[a]],
                          "gene_ontology") %>%
            rest %>% .$fields %>% .$gene_ontology %>% .$data
        if (!is.null(rest)) {
            mclapply(seq_along(rest), function(b) {
                lapply(seq_along(rest[[b]]), function(c) {
                    paste(identifier = rest[[b]][[c]]$term_description$id,
                          name = rest[[b]][[c]]$term_description$label,
                          sep = "~")
                }) %>% unique %>% toString
            }) %>%
                set_names(camel(paste0(
                    "wormbaseGeneOntology_", names(rest)))) %>%
                as_tibble %>%
                # [fix] check that this works
                mutate(gene = identifier[[a]])
        } else {
            tibble()
        }
    }) %>% bind_rows
}
