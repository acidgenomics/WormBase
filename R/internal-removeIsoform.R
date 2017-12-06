.removeIsoform <- function(sequence) {
    grep <- "^([A-Z0-9]+)\\.([0-9]+)[a-z]$"
    if (any(grepl(grep, sequence))) {
        warning("Sequence identifiers should not end with an isoform")
        gsub(pattern = grep,
             replacement = "\\1.\\2",
             x = sequence)
    } else {
        sequence
    }
}
