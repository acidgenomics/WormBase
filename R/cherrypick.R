#' Cherrypick RNAi clones by keyword
#' @export
#' @importFrom dplyr arrange_ right_join
#' @param identifier Keyword identifier
#' @return RNAi clone list by gene
cherrypick <- function(identifier) {
    identifier %>%
        uniqueIdentifier %>%
        gene(format = "keyword") %>%
        dplyr::right_join(rnai(.$gene, format = "gene"), by = defaultCol) %>%
        dplyr::arrange_(.dots = names(.))
}
