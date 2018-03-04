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
rnaiPhenotypes <- function(version = NULL, dir= ".") {
    .assertFormalVersion(version)
    dir <- initializeDirectory(dir)
    if (is.null(version)) {
        version <- "current-production-release"
    }
    remoteDir <- paste(
        "ftp://ftp.wormbase.org",
        "pub",
        "wormbase",
        "releases",
        version,
        "ONTOLOGY",
        sep = "/"
    )
    file <- transmit(
        remoteDir = remoteDir,
        pattern = "rnai_phenotypes_quick",
        localDir = dir,
        compress = TRUE
    )
    assert_is_of_length(file, 1L)
    data <- read_tsv(
        file = as.character(file),
        col_names = c("gene", "sequence", "rnaiPhenotypes")
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
