#' RNAi phenotypes
#'
#' @inheritParams params
#'
#' @return `tbl_df`.
#' @export
#'
#' @examples
#' x <- rnaiPhenotypes(progress = FALSE)
#' glimpse(x)
rnaiPhenotypes <- function(
    version = NULL,
    dir = ".",
    progress = FALSE
) {
    assert(isFlag(progress))
    # Allow the user to disable progress bar.
    if (!isTRUE(progress)) {
        pblapply <- lapply
    }
    file <- .transmit(
        subdir = "ONTOLOGY",
        pattern = "rnai_phenotypes_quick",
        version = version,
        dir = dir,
        compress = TRUE
    )
    data <- read_tsv(
        file = as.character(file),
        col_names = c("geneID", "sequence", "rnaiPhenotypes")
    )
    # Use `sequence` from `geneID()` return.
    data[["sequence"]] <- NULL
    list <- pblapply(
        X = strsplit(data[["rnaiPhenotypes"]], ", "),
        FUN = function(x) {
            sort(unique(x))
        }
    )
    data[["rnaiPhenotypes"]] <- list
    data
}
