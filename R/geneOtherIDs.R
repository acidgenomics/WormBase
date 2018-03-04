#' Other Gene Identifiers
#'
#' @family Annotation File Functions
#'
#' @importFrom dplyr mutate
#' @importFrom magrittr set_rownames
#' @importFrom tibble as_tibble
#'
#' @inheritParams annotationFile
#'
#' @return Gene [tibble].
#' @export
#'
#' @examples
#' geneOtherIDs() %>% glimpse()
geneOtherIDs <- function(version = NULL, dir = ".") {
    file <- annotationFile(
        file = "geneOtherIDs",
        version = version,
        dir = dir
    )
    read_lines(file) %>%
        # Remove status, already present in geneIDs file
        gsub("\t(Dead|Live)", "", .) %>%
        # Remove `CELE_*` identifiers
        gsub("\t(CELE_[A-Z0-9\\.]+)", "", .) %>%
        # Convert tabs to commas for identifiers
        gsub("\t", "|", .) %>%
        # Add tab back in to separate \code{gene} for row names
        gsub("^(WBGene\\d+)(\\|)?", "\\1\t", .) %>%
        strsplit("\t") %>%
        do.call(rbind, .) %>%
        as_tibble() %>%
        set_colnames(c("gene", "otherIDs")) %>%
        mutate(otherIDs = strsplit(.data[["otherIDs"]], "\\|"))
}
