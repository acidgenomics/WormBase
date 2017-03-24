#' @importFrom stats na.omit
#' @keywords internal
uniqueIdentifier <- function(identifier) {
    if (missing(identifier)) {
        stop("An identifier is required.")
    } else if (!is.character(identifier)) {
        stop("Identifier must be a character vector.")
    }
    # Fix WBGene capitalization and alert user if necessary:
    grep <- "^(WBGENE|WBgene|Wbgene|wbgene)(\\d{8})$"
    if (any(grepl(grep, identifier))) {
        message("WormBase gene identifiers should begin with `WBGene`.")
        identifier <- gsub(grep, "WBGene\\2", identifier)
    }
    identifier %>%
        stats::na.omit(.) %>%
        unique %>%
        sort
}
