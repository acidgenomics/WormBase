#' Cherrypick RNAi clones by keyword
#'
#' @export
#' @importFrom dplyr arrange_ right_join
#' @param keyword Keyword
#' @return RNAi clone list by gene
#'
#' @examples
#' cherrypick("transcription")
cherrypick <- function(keyword) {
    gene(keyword, format = "keyword") %>%
        dplyr::right_join(rnai(.$gene, format = "gene"),
                          by = c("gene", "sequence", "name")) %>%
        dplyr::arrange_(.dots = names(.))
}
