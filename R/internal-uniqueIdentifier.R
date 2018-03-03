.uniqueIdentifier <- function(identifier) {
    assert_is_character(identifier)
    # Fix WBGene capitalization and alert user if necessary:
    grep <- "^(WBGENE|WBgene|Wbgene|wbgene)(\\d{8})$"
    if (any(grepl(grep, identifier))) {
        warn("WormBase gene identifiers should begin with `WBGene`")
        identifier <- gsub(grep, "WBGene\\2", identifier)
    }
    identifier %>%
        na.omit() %>%
        unique() %>%
        sort()
}
