#' RNAi phenotypes
#'
#' @note Updated 2019-07-27.
#' @export
#'
#' @inheritParams params
#'
#' @return `tbl_df`.
#'
#' @examples
#' ## WormBase FTP server must be accessible.
#' if (!is.null(curl::nslookup("ftp.wormbase.org"))) {
#'     x <- rnaiPhenotypes()
#'     glimpse(x)
#' }
rnaiPhenotypes <- function(version = NULL, progress = FALSE) {
    pblapply <- .pblapply(progress = progress)
    file <- .transmit(
        subdir = "ONTOLOGY",
        pattern = "rnai_phenotypes_quick",
        version = version,
        compress = TRUE
    )
    data <- read_tsv(
        file = unname(file),
        col_names = c("geneID", "sequence", "rnaiPhenotypes")
    )
    list <- pblapply(
        X = strsplit(data[["rnaiPhenotypes"]], ", "),
        FUN = function(x) {
            sort(unique(x))
        }
    )
    data %>%
        mutate(
            ## Use `sequence` from `geneID()` return instead.
            !!sym("sequence") := NULL,
            !!sym("rnaiPhenotypes") := !!list
        ) %>%
        filter(grepl(pattern = genePattern, x = !!sym("geneID"))) %>%
        arrange(!!sym("geneID"))
}

formals(rnaiPhenotypes)[["version"]] <- versionArg
