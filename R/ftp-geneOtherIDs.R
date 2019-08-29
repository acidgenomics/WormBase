#' Other gene identifiers
#'
#' @note As of WS269 release, some non-N2 gene IDs are included in the flat
#'   files available on the WormBase FTP server. These annotations are removed
#'   from the return here, using grep matching to return only `WBGene` entries.
#'
#' @note Updated 2019-08-28.
#' @export
#'
#' @inheritParams params
#' @inheritParams acidroxygen::params
#'
#' @return `DataFrame`.
#'
#' @examples
#' ## WormBase FTP server must be accessible.
#' tryCatch(
#'     expr = geneOtherIDs(),
#'     error = function(e) e
#' )
geneOtherIDs <- function(version = NULL) {
    file <- .annotationFile(pattern = "geneOtherIDs", version = version)
    x <- import(file, format = "lines")
    ## Remove status. Already present in geneIDs file.
    x <- gsub("\t(Dead|Live)", "", x)
    ## Remove `CELE_*` identifiers.
    x <- gsub("\t(CELE_[A-Z0-9\\.]+)", "", x)
    ## Convert tabs to commas for identifiers.
    x <- gsub("\t", "|", x)
    ## Add tab back in to separate \code{gene} for row names.
    x <- gsub("^(WBGene\\d+)(\\|)?", "\\1\t", x)
    ## Break out the chain and evaluate.
    x <- strsplit(x, "\t")
    x <- do.call(rbind, x)
    x <- as.data.frame(x, stringsAsFactors = FALSE)
    x <- as(x, "DataFrame")
    colnames(x) <- c("geneID", "geneOtherIDs")
    keep <- grepl(pattern = genePattern, x = x[["geneID"]])
    x <- x[keep, , drop = FALSE]
    x <- x[order(x[["geneID"]]), , drop = FALSE]
    x[["geneOtherIDs"]] <- strsplit(
        x = as.character(x[["geneOtherIDs"]]),
        split = "\\|"
    )
    x
}

formals(geneOtherIDs)[["version"]] <- versionArg
