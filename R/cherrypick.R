#' Cherrypick RNAi clones by keyword
#' @export
#' @importFrom dplyr arrange_ right_join
#' @param identifier Keyword identifier
#' @param format Identifier format
#' @param controlWells Number of control wells per cherrypick plate
#' @return RNAi clone list by gene
cherrypick <- function(identifier,
                       format = "keyword",
                       controlWells = 3) {
    identifier %>%
        uniqueIdentifier %>%
        gene(format = format) %>%
        dplyr::right_join(rnai(.$gene, format = "gene"), by = defaultCol) %>%
        dplyr::arrange_(.dots = names(.))
}

# See Natalie's cherrypick for data example
# cherrypick plate identifiers
# control wells: default = 3
