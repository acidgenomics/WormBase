#' Cherrypick RNAi clones by keyword
#' @export
#' @importFrom dplyr arrange_ right_join
#' @importFrom stats setNames
#' @importFrom tidyr unnest
#' @param identifier Keyword identifier
#' @param format Identifier format
#' @param ahringer384 Include Ahringer 384 well library
#' @param ahringer96 Include Ahringer 96 well library
#' @param orfeome96 Include ORFeome 96 well library
#' @param plates Reference character of plates to pick from
#' @return RNAi clone list by gene
cherrypick <- function(identifier,
                       format = "keyword",
                       ahringer384 = TRUE,
                       ahringer96 = FALSE,
                       orfeome96 = TRUE,
                       plates = NULL) {
    return <- identifier %>%
        uniqueIdentifier %>%
        gene(format = format) %>%
        dplyr::right_join(rnai(.$gene, format = "gene"), by = defaultCol) %>%
        dplyr::mutate_(.dots = stats::setNames(list(quote(strsplit(clone, ", "))), "clone")) %>%
        tidyr::unnest(.) %>%
        dplyr::arrange_(.dots = "clone")
    if (!isTRUE(ahringer384)) {
        return <- return[!grepl("^ahringer384", return$clone), ]
    }
    if (!isTRUE(ahringer96)) {
        return <- return[!grepl("^ahringer96", return$clone), ]
    }
    if (!isTRUE(orfeome96)) {
        return <- return[!grepl("^orfeome96", return$clone), ]
    }
    if (!is.null(plates)) {
        grep <- paste0("^(", paste(plates, collapse = "|"), ")-\\D\\d{2}$")
        return <- return[grepl(grep, return$clone), ]
    }
    return
}
