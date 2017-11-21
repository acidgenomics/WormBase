#' Cherrypick RNAi Clones by Keyword
#'
#' @importFrom dplyr arrange mutate right_join
#' @importFrom rlang !! sym
#' @importFrom tidyr unnest
#'
#' @param identifier Keyword identifier.
#' @param format Identifier format.
#' @param ahringer384 Include Ahringer 384 well library.
#' @param ahringer96 Include Ahringer 96 well library.
#' @param orfeome96 Include ORFeome 96 well library.
#' @param plates *Optional*. Character vector of reference plates (for
#'   subsetting).
#'
#' @return RNAi clone [list] by gene.
#' @export
cherrypick <- function(
    identifier,
    format = "keyword",
    ahringer384 = TRUE,
    ahringer96 = FALSE,
    orfeome96 = TRUE,
    plates) {
    df <- uniqueIdentifier(identifier) %>%
        gene(format = format) %>%
        right_join(
            rnai(.[["gene"]], format = "gene"),
            by = defaultCol) %>%
        mutate(clone = strsplit(.data[["clone"]], ", ")) %>%
        unnest() %>%
        arrange(!!sym("clone"))
    if (!isTRUE(ahringer384)) {
        df <- df[!grepl("^ahringer384", df[["clone"]]), ]
    }
    if (!isTRUE(ahringer96)) {
        df <- df[!grepl("^ahringer96", df[["clone"]]), ]
    }
    if (!isTRUE(orfeome96)) {
        df <- df[!grepl("^orfeome96", df[["clone"]]), ]
    }
    if (!missing(plates)) {
        if (!is.character(plates)) {
            stop("Plates must be a character vector")
        }
        grep <- paste0("^(", paste(plates, collapse = "|"), ")-\\D\\d{2}$")
        df <- df[grepl(grep, df[["clone"]]), ]
    }
    return(df)
}
