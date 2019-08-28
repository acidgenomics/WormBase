#' RNAi phenotypes
#'
#' @note Updated 2019-08-28.
#' @export
#'
#' @inheritParams params
#'
#' @return `DataFrame`.
#'
#' @examples
#' ## WormBase FTP server must be accessible.
#' tryCatch(
#'     expr = rnaiPhenotypes(),
#'     error = function(e) e
#' )
rnaiPhenotypes <- function(
    version = NULL,
    BPPARAM = BiocParallel::SerialParam(progressbar = TRUE)
) {
    file <- .transmit(
        subdir = "ONTOLOGY",
        pattern = "rnai_phenotypes_quick",
        version = version,
        compress = TRUE
    )
    x <- import(
        file = file,
        format = "tsv",
        colnames = c("geneID", "sequence", "rnaiPhenotypes")
    )
    ## Using `sequence` from `geneID()` return instead.
    x[["sequence"]] <- NULL
    x <- as(x, "DataFrame")
    pheno <- strsplit(x[["rnaiPhenotypes"]], ", ")
    pheno <- bplapply(
        X = pheno,
        FUN = function(x) {
            sort(unique(x))
        },
        BPPARAM = BPPARAM
    )
    x[["rnaiPhenotypes"]] <- pheno
    keep <- grepl(pattern = genePattern, x = x[["geneID"]])
    x <- x[keep, , drop = FALSE]
    x <- x[order(x[["geneID"]]), , drop = FALSE]
    x
}

formals(rnaiPhenotypes)[["version"]] <- versionArg
