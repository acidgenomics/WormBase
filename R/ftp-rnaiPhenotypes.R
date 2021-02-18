#' RNAi phenotypes
#'
#' @note Updated 2021-02-17.
#' @export
#'
#' @inheritParams params
#' @inheritParams AcidRoxygen::params
#'
#' @return `DataFrame`.
#'
#' @examples
#' ## WormBase FTP server must be accessible.
#' tryCatch(
#'     expr = rnaiPhenotypes(),
#'     error = function(e) e
#' )
rnaiPhenotypes <- function(version = NULL) {
    file <- .ontologyFile(
        stem = "rnai_phenotypes_quick",
        version = version
    )
    x <- import(
        file = file,
        format = "tsv",
        colnames = c("geneId", "sequence", "rnaiPhenotypes")
    )
    ## Using `sequence` from `geneID()` return instead.
    x[["sequence"]] <- NULL
    x <- as(x, "DataFrame")
    pheno <- strsplit(x[["rnaiPhenotypes"]], ", ")
    pheno <- CharacterList(pheno)
    pheno <- sort(unique(pheno))
    x[["rnaiPhenotypes"]] <- pheno
    keep <- grepl(pattern = .genePattern, x = x[["geneId"]])
    x <- x[keep, , drop = FALSE]
    x <- x[order(x[["geneId"]]), , drop = FALSE]
    x
}

formals(rnaiPhenotypes)[["version"]] <- .versionArg
