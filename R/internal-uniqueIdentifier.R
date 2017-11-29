.uniqueIdentifier <- function(identifier) {
    if (missing(identifier)) {
        stop("Identifier is required")
    } else if (!is.character(identifier)) {
        stop("Identifier must be a character vector")
    }
    # Fix WBGene capitalization and alert user if necessary:
    grep <- "^(WBGENE|WBgene|Wbgene|wbgene)(\\d{8})$"
    if (any(grepl(pattern = grep, x = identifier))) {
        message("WormBase gene identifiers should begin with `WBGene`")
        identifier <- gsub(
            pattern = grep,
            replacement = "WBGene\\2",
            x = identifier)
    }
    identifier %>%
        na.omit() %>%
        unique() %>%
        sort()
}
