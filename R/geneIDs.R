#' Gene Identifiers
#'
#' @family FTP File Functions
#'
#' @inheritParams general
#'
#' @return `tbl_df`.
#' @export
#'
#' @examples
#' geneIDs() %>% glimpse()
geneIDs <- function(version = NULL, dir = ".") {
    file <- .annotationFile(
        pattern = "geneIDs",
        version = version,
        dir = dir
    )
    data <- read_csv(
        file = as.character(file),
        col_names = FALSE,
        na = "",
        progress = FALSE
    )
    data <- data[, 2L:5L]
    colnames(data) <- c("geneID", "geneName", "sequence", "status")
    data
}
