#' RNAi Phenotypes
#'
#' @family FTP File Functions
#'
#' @importFrom basejump transmit
#' @importFrom BiocParallel bplapply
#' @importFrom fs file_move
#'
#' @inheritParams general
#'
#' @return Gene [tibble].
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
        col_names = c("gene", "sequence", "rnaiPhenotypes"),
        progress = FALSE
    )
    data[["sequence"]] <- NULL
    list <- bplapply(
        X = strsplit(data[["rnaiPhenotypes"]], ", "),
        FUN = function(x) {
            sort(unique(x))
        }
    )
    data[["rnaiPhenotypes"]] <- list
    data
}
