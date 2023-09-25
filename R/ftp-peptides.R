#' Peptides
#'
#' @note Updated 2023-09-25.
#' @export
#'
#' @inheritParams params
#' @inheritParams AcidRoxygen::params
#'
#' @return `SplitDataFrameList`.
#' Split by `geneId` column.
#'
#' @examples
#' x <- peptides()
#' print(x)
peptides <- function(release = NULL) {
    file <- .assemblyFile(stem = "wormpep_package.tar.gz", release = release)
    tempdir <- tempdir2()
    releaseNumber <- strMatch(
        x = file,
        pattern = "WS([[:digit:]]{3})",
        fixed = FALSE
    )[1L, 2L]
    ## Extract the individual table.
    wormpepTable <- paste0("wormpep.table", releaseNumber)
    status <- untar(tarfile = file, files = wormpepTable, exdir = tempdir)
    assert(identical(status, 0L))
    x <- import(con = file.path(tempdir, wormpepTable), format = "lines")
    unlink2(tempdir)
    x <- mclapply(
        X = x,
        FUN = function(x) {
            sequence <- strMatch(
                x = x,
                pattern = "^>([A-Za-z0-9\\.]+)",
                fixed = FALSE
            )[1L, 2L]
            ## Attempt to match quoted values first (e.g. product).
            pattern <- "([a-z]+)=(\"[^\"]+\"|[^\\s]+)"
            ## Set up our matrix of key value pairs.
            ## FIXME Rework using strMatch.
            pairs <- stringi::stri_match_all_regex(str = x, pattern = pattern)[[1L]]
            ## FIXME How to do this with our matching function?
            ## > pairs <- strMatch(x = x, pattern = pattern, fixed = FALSE)
            ## Remove any escaped quotes.
            pairs <- gsub("\"", "", pairs)
            out <- c(pairs[, 3L])
            names(out) <- pairs[, 2L]
            out[["sequence"]] <- sequence
            out
        }
    )
    x <- rbindToDataFrame(x)
    colnames(x)[colnames(x) == "gene"] <- "geneId"
    x <- x[, unique(c("geneId", colnames(x)))]
    keep <- grepl(pattern = .genePattern, x = x[["geneId"]])
    x <- x[keep, , drop = FALSE]
    x <- x[
        order(x[["geneId"]], x[["sequence"]], x[["wormpep"]]), ,
        drop = FALSE
    ]
    x <- split(x, f = x[["geneId"]])
    assert(is(x, "SplitDataFrameList"))
    x
}

formals(peptides)[["release"]] <- .releaseArg
