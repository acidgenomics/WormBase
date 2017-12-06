#' Cherrypick RNAi Clones by Keyword
#'
#' @importFrom dplyr arrange everything mutate pull right_join select
#' @importFrom rlang !! sym
#' @importFrom tidyr unnest
#'
#' @param identifier Keyword identifier.
#' @param format Identifier format.
#'
#' @return RNAi clone [list] by gene.
#' @export
#'
#' @examples
#' cherrypick("unfolded protein response", format = "keyword") %>%
#'     glimpse()
cherrypick <- function(
    identifier,
    format = "keyword") {
    identifier <- .uniqueIdentifier(identifier)
    gene <- gene(identifier, format = format)
    if (!nrow(gene)) {
        return(NULL)
    }
    rnai <- pull(gene, "gene") %>%
        rnai(format = "gene")
    rnai[["genePair"]] <- NULL
    df <- left_join(rnai, gene, by = defaultCol)
    select(df, unique(c(format, defaultCol)), everything())
}
