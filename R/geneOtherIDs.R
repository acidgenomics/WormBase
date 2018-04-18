#' Other Gene Identifiers
#'
#' @family FTP File Functions
#'
#' @inheritParams general
#'
#' @return `tbl_df`.
#' @export
#'
#' @examples
#' geneOtherIDs() %>% glimpse()
geneOtherIDs <- function(version = NULL, dir = ".") {
    file <- .annotationFile(
        pattern = "geneOtherIDs",
        version = version,
        dir = dir
    )
    read_lines(
        file = as.character(file),
        progress = FALSE
    ) %>%
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
        set_colnames(c("geneID", "geneOtherIDs")) %>%
        mutate(geneOtherIDs = strsplit(!!sym("geneOtherIDs"), "\\|"))
}
