#' Peptides
#'
#' @note Updated 2021-03-12.
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
    ## FIXME Need to import tempdir2 into NAMESPACE.
    tempdir <- AcidBase::tempdir2()
    ## Grep the verion number.
    releaseNumber <- str_match(file, "WS([[:digit:]]{3})")[1L, 2L]
    ## Extract the individual table.
    wormpepTable <- paste0("wormpep.table", releaseNumber)
    status <- untar(tarfile = file, files = wormpepTable, exdir = tempdir)
    assert(identical(status, 0L))
    x <- import(file = file.path(tempdir, wormpepTable), format = "lines")
    x <- lapply(
        X = x,
        FUN = function(x) {
            sequence <- str_match(x, "^>([A-Za-z0-9\\.]+)")[[2L]]
            ## Attempt to match quoted values first (e.g. product).
            pattern <- "([a-z]+)=(\"[^\"]+\"|[^\\s]+)"
            # Set up our matrix of key value pairs.
            pairs <- str_match_all(x, pattern)[[1L]]
            ## Remove any escaped quotes.
            pairs <- gsub("\"", "", pairs)
            out <- c(pairs[, 3L])
            names(out) <- pairs[, 2L]
            out[["sequence"]] <- sequence
            out
        }
    )
    ## This step may need to be optimized.
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
