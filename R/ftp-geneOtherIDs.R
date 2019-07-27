#' Other gene identifiers
#'
#' @note As of WS269 release, some non-N2 gene IDs are included in the flat
#'   files available on the WormBase FTP server. These annotations are removed
#'   from the return here, using grep matching to return only `WBGene` entries.
#'
#' @note Updated 2019-07-27.
#' @export
#'
#' @inheritParams params
#'
#' @return `tbl_df`.
#'
#' @examples
#' ## WormBase FTP server must be accessible.
#' if (!is.null(curl::nslookup("ftp.wormbase.org"))) {
#'     x <- geneOtherIDs()
#'     glimpse(x)
#'  }
geneOtherIDs <- function(version = NULL) {
    file <- .annotationFile(pattern = "geneOtherIDs", version = version)
    file %>%
        unname() %>%
        read_lines(progress = FALSE) %>%
        ## Remove status. Already present in geneIDs file.
        gsub("\t(Dead|Live)", "", .) %>%
        ## Remove `CELE_*` identifiers.
        gsub("\t(CELE_[A-Z0-9\\.]+)", "", .) %>%
        ## Convert tabs to commas for identifiers.
        gsub("\t", "|", .) %>%
        ## Add tab back in to separate \code{gene} for row names.
        gsub("^(WBGene\\d+)(\\|)?", "\\1\t", .) %>%
        ## Break out the chain and evaluate.
        strsplit("\t") %>%
        do.call(rbind, .) %>%
        set_colnames(c("geneID", "geneOtherIDs")) %>%
        as_tibble() %>%
        filter(grepl(pattern = genePattern, x = !!sym("geneID"))) %>%
        arrange(!!sym("geneID")) %>%
        mutate(!!sym("geneOtherIDs") := strsplit(!!sym("geneOtherIDs"), "\\|"))
}

formals(geneOtherIDs)[["version"]] <- versionArg
