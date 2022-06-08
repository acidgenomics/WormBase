#' Best BLASTP hits
#'
#' @note Updated 2022-06-08.
#' @export
#'
#' @inheritParams params
#' @inheritParams AcidRoxygen::params
#'
#' @return `SplitDataFrameList`.
#' Split by `wormpep` column.
#'
#' @examples
#' x <- blastp()
#' print(x)
blastp <- function(release = NULL) {
    file <- .assemblyFile(
        stem = "best_blastp_hits.txt.gz",
        release = release
    )
    x <- import(file, format = "csv", colnames = FALSE)
    x <- as(x, "DataFrame")
    x <- x[, c(1L, 4L, 5L)]
    colnames(x) <- c("wormpep", "peptide", "eValue")
    keep <- grepl("^ENSEMBL:ENSP\\d{11}$", x[["peptide"]])
    x <- x[keep, , drop = FALSE]
    x <- x[order(x[["wormpep"]], x[["eValue"]]), , drop = FALSE]
    x[["peptide"]] <- stri_sub(x[["peptide"]], from = 9L)
    x[["eValue"]] <- as.numeric(x[["eValue"]])
    x <- split(x, f = x[["wormpep"]])
    assert(is(x, "SplitDataFrameList"))
    x
}

formals(blastp)[["release"]] <- .releaseArg
