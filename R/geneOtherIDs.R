#' Other gene identifiers
#'
#' @note As of WS269 release, some non-N2 gene IDs are included in the flat
#'   files available on the WormBase FTP server. These annotations are removed
#'   from the return here, using grep matching to return only `WBGene` entries.
#'
#' @inheritParams params
#'
#' @return `tbl_df`.
#' @export
#'
#' @examples
#' x <- geneOtherIDs()
#' glimpse(x)

## Updated 2019-07-24.
geneOtherIDs <- function(version = NULL) {
    file <- .annotationFile(pattern = "geneOtherIDs", version = version)
    read_lines(file, progress = FALSE) %>%
        ## Remove status. Already present in geneIDs file.
        gsub("\t(Dead|Live)", "", .) %>%
        ## Remove `CELE_*` identifiers.
        gsub("\t(CELE_[A-Z0-9\\.]+)", "", .) %>%
        ## Convert tabs to commas for identifiers.
        gsub("\t", "|", .) %>%
        ## Add tab back in to separate \code{gene} for row names.
        gsub("^(WBGene\\d+)(\\|)?", "\\1\t", .) %>%
        strsplit("\t") %>%
        do.call(rbind, .) %>%
        as_tibble() %>%
        set_colnames(c("geneID", "geneOtherIDs")) %>%
        filter(grepl(pattern = genePattern, x = !!sym("geneID"))) %>%
        arrange(!!sym("geneID")) %>%
        mutate(!!sym("geneOtherIDs") := strsplit(!!sym("geneOtherIDs"), "\\|"))
}
