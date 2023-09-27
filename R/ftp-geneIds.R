#' Gene identifiers
#'
#' @note As of WS269 release, some non-N2 gene IDs are included in the flat
#' files available on the WormBase FTP server. These annotations are removed
#' from the return here, using grep matching to return only `WBGene` entries.
#'
#' @note Updated 2021-02-18.
#' @export
#'
#' @inheritParams params
#' @inheritParams AcidRoxygen::params
#'
#' @return `DataFrame`.
#'
#' @examples
#' x <- geneIds()
#' print(x)
geneIds <- function(release = NULL) {
    file <- .annotationFile(stem = "geneIds.txt.gz", release = release)
    x <- import(file, format = "csv", colnames = FALSE)
    x <- as(x, "DFrame")
    x <- x[, 2L:5L]
    colnames(x) <- c("geneId", "geneName", "sequence", "status")
    keep <- grepl(pattern = .genePattern, x = x[["geneId"]])
    x <- x[keep, , drop = FALSE]
    x <- x[order(x[["geneId"]]), , drop = FALSE]
    rownames(x) <- x[["geneId"]]
    x
}

formals(geneIds)[["release"]] <- .releaseArg
