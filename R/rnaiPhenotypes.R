#' RNAi Phenotypes
#'
#' @family FTP File Functions
#'
#' @inheritParams general
#'
#' @return `tbl_df`.
#' @export
#'
#' @examples
#' rnaiPhenotypes() %>% glimpse()
rnaiPhenotypes <- function(version = NULL, dir = ".") {
    file <- .transmit(
        subdir = "ONTOLOGY",
        pattern = "rnai_phenotypes_quick",
        version = version,
        dir = dir,
        compress = TRUE
    )
    data <- read_tsv(
        file = as.character(file),
        col_names = c("geneID", "sequence", "rnaiPhenotypes"),
        progress = FALSE
    )
    # Use `sequence` from `geneID()` return
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
