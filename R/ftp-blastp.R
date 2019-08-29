#' Best BLASTP hits
#'
#' @note Updated 2019-08-28.
#' @export
#'
#' @inheritParams params
#' @inheritParams acidroxygen::params
#'
#' @return `SplitDataFrameList`.
#' Split by `wormpep` column.
#'
#' @examples
#' ## WormBase FTP server must be accessible.
#' tryCatch(
#'     expr = blastp(),
#'     error = function(e) e
#' )
blastp <- function(version = NULL) {
    file <- .assemblyFile(
        pattern = "best_blastp_hits",
        version = version
    )
    x <- import(file, colnames = FALSE)
    x <- as(x, "DataFrame")
    x <- x[, c(1L, 4L, 5L)]
    colnames(x) <- c("wormpep", "peptide", "eValue")
    keep <- grepl("^ENSEMBL:ENSP\\d{11}$", x[["peptide"]])
    x <- x[keep, , drop = FALSE]
    x <- x[order(x[["wormpep"]], x[["eValue"]]), , drop = FALSE]
    x[["peptide"]] <- str_sub(x[["peptide"]], 9L)
    x[["eValue"]] <- as.numeric(x[["eValue"]])
    split(x, f = x[["wormpep"]])
}

formals(blastp)[["version"]] <- versionArg
