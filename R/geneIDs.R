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
