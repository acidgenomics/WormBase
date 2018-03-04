#' Gene Identifiers
#'
#' @family Annotation File Functions
#'
#' @importFrom readr read_csv
#'
#' @inheritParams annotationFile
#'
#' @return Gene [tibble].
#' @export
#'
#' @examples
#' geneIDs() %>% glimpse()
geneIDs <- function(version = NULL, dir = ".") {
    file <- annotationFile(
        file = "geneIDs",
        version = version,
        dir = dir
    )
    data <- read_csv(
        file = file,
        col_names = c("X1", "gene", "name", "sequence", "status"),
        na = ""
    )
    data[["X1"]] <- NULL
    data
}
