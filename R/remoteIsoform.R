#' @keywords internal
removeIsoform <- function(sequence) {
    grep <- "^([A-Z0-9]+)\\.([0-9]+)[a-z]$"
    if (any(grepl(grep, sequence))) {
        message("Sequence identifiers should not end with an isoform letter.")
        gsub(grep, "\\1.\\2", sequence)
    } else {
        sequence
    }
}
