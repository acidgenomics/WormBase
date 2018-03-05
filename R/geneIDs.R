#' Gene Identifiers
#'
#' @family FTP File Functions
#'
#' @importFrom readr read_csv
#'
#' @inheritParams general
#'
#' @return Gene [tibble].
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
        col_names = c("X1", "gene", "symbol", "sequence", "status"),
        na = "",
        progress = FALSE
    )
    data[["X1"]] <- NULL
    data
}
