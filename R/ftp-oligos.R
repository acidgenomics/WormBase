#' PCR oligo sequences
#'
#' @note Updated 2019-08-28.
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
#'     expr = oligos(),
#'     error = function(e) e
#' )
oligos <- function(version = NULL) {
    file <- .annotationFile(pattern = "pcr_product2gene", version = version)
    ## `pcr_product2gene.txt` file is malformed, so let's parse as lines.
    x <- import(file, format = "lines")
    x <- str_match(x, "^([^\t]+)\t(WBGene\\d{8})")
    x <- x[, c(2L:3L)]
    x <- as.data.frame(x, stringsAsFactors = FALSE)
    colnames(x) <- c("oligo", "geneId")
    x <- aggregate(
        formula = formula("oligo~geneId"),
        data = x,
        FUN = function(x) {
            x <- unique(x)
            x <- sort(x)
            x <- list(x)
            x
        }
    )
    x <- as(x, "DataFrame")
    keep <- grepl(pattern = genePattern, x = x[["geneId"]])
    x <- x[keep, , drop = FALSE]
    x <- x[order(x[["geneId"]]), , drop = FALSE]
    x
}

formals(oligos)[["version"]] <- versionArg
