#' Gene identifiers
#'
#' @note As of WS269 release, some non-N2 gene IDs are included in the flat
#'   files available on the WormBase FTP server. These annotations are removed
#'   from the return here, using grep matching to return only `WBGene` entries.
#'
#' @note Updated 2021-02-17.
#' @export
#'
#' @inheritParams params
#' @inheritParams AcidRoxygen::params
#'
#' @return `DataFrame`.
#'
#' @examples
#' ## WormBase FTP server must be accessible.
#' tryCatch(
#'     expr = geneIDs(),
#'     error = function(e) e
#' )
geneIDs <- function(version = NULL) {
    file <- .annotationFile(stem = "geneIDs.txt.gz", version = version)
    x <- import(file, format = "csv", colnames = FALSE)
    x <- as(x, "DataFrame")
    x <- x[, 2L:5L]
    colnames(x) <- c("geneId", "geneName", "sequence", "status")
    keep <- grepl(pattern = .genePattern, x = x[["geneId"]])
    x <- x[keep, , drop = FALSE]
    x <- x[order(x[["geneId"]]), , drop = FALSE]
    x
}

formals(geneIDs)[["version"]] <- .versionArg
