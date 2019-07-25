#' Gene identifiers
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
#' x <- geneIDs()
#' glimpse(x)

## Updated 2019-07-24.
geneIDs <- function(version = NULL) {
    file <- .annotationFile(pattern = "geneIDs", version = version)
    file %>%
        unname() %>%
        import(colnames = FALSE) %>%
        as_tibble() %>%
        .[, 2L:5L] %>%
        set_colnames(c("geneID", "geneName", "sequence", "status")) %>%
        filter(grepl(pattern = genePattern, x = !!sym("geneID"))) %>%
        arrange(!!sym("geneID"))
}

formals(geneIDs)[["version"]] <- versionArg
