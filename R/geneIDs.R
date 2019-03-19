#' Gene identifiers
#'
#' @inheritParams params
#'
#' @return `tbl_df`.
#' @export
#'
#' @examples
#' x <- geneIDs()
#' glimpse(x)
geneIDs <- function(version = NULL, dir = ".") {
    # Temporary fix for buggy WS269 file.
    if (is.null(version)) {
        message(paste(
            "Gene identifier file is currently malformed for current",
            "production release (WS269).",
            "Returning WS268 identifiers instead."
        ))
        version <- "WS268"
    }
    file <- .annotationFile(
        pattern = "geneIDs",
        version = version,
        dir = dir
    )
    data <- import(file = unname(file), colnames = FALSE)
    data <- data[, 2L:5L]
    colnames(data) <- c("geneID", "geneName", "sequence", "status")
    data
}
