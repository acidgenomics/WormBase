#' Cherrypick RNAi clones by keyword
#' @export
#' @importFrom dplyr arrange_ right_join
#' @importFrom tidyr unnest
#' @param identifier Keyword identifier
#' @param format Identifier format
#' @param controls Names of control wells
#' @param ahringer384 Include Ahringer 384 well library
#' @param ahringer96 Include Ahringer 96 well library
#' @param orfeome96 Include ORFeome 96 well library
#' @return RNAi clone list by gene
cherrypick <- function(identifier,
                       format = "keyword",
                       controls = 3,
                       ahringer384 = TRUE,
                       ahringer96 = FALSE,
                       orfeome96 = TRUE) {
    return <- identifier %>%
        uniqueIdentifier %>%
        gene(format = format) %>%
        dplyr::right_join(rnai(.$gene, format = "gene"), by = defaultCol) %>%
        dplyr::mutate(clone = strsplit(clone, ", ")) %>%
        tidyr::unnest(.) %>%
        dplyr::arrange_(.dots = c("gene", "clone"))
    if (!isTRUE(ahringer384)) {
        return <- dplyr::filter_(return, quote(!grepl("^ahringer384", clone)))
    }
    if (!isTRUE(ahringer96)) {
        return <- dplyr::filter_(return, quote(!grepl("^ahringer96", clone)))
    }
    if (!isTRUE(orfeome96)) {
        return <- dplyr::filter_(return, quote(!grepl("^orfeome96", clone)))
    }
    return
}

# See Natalie's cherrypick for data example
# cherrypick plate identifiers
# control wells: default = 3
