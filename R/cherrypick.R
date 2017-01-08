#' Cherrypick RNAi clones by keyword
#'
#' @export
#' @importFrom dplyr arrange_ right_join
#' @param keyword Keyword
#' @return RNAi clone list by gene
cherrypick <- function(keyword) {
    gene(keyword, format = "keyword") %>%
        dplyr::right_join(rnai(.$gene, format = "gene"), by = simpleCol) %>%
        dplyr::arrange_(.dots = names(.))
}
