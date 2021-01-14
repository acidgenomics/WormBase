#' Peptides
#'
#' @note Updated 2020-01-26.
#' @export
#'
#' @inheritParams params
#' @inheritParams AcidRoxygen::params
#'
#' @return `SplitDataFrameList`.
#' Split by `geneId` column.
#'
#' @examples
#' ## WormBase FTP server must be accessible.
#' tryCatch(
#'     expr = peptides(),
#'     error = function(e) e
#' )
peptides <- function(
    version = NULL,
    BPPARAM = BiocParallel::bpparam()  # nolint
) {
    file <- .assemblyFile(pattern = "wormpep_package", version = version)
    tempdir <- tempdir()
    ## Grep the verion number.
    versionNumber <- str_match(file, "WS([[:digit:]]{3})")[1L, 2L]
    ## Extract the individual table.
    wormpepTable <- paste0("wormpep.table", versionNumber)
    untar(
        tarfile = file,
        files = wormpepTable,
        exdir = tempdir
    )
    x <- import(file = file.path(tempdir, wormpepTable), format = "lines")
    cli_alert("Processing peptides.")
    x <- bplapply(
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
            as.data.frame(t(out), stringsAsFactors = TRUE)
        },
        BPPARAM = BPPARAM
    )
    x <- rbindlist(x, fill = TRUE)
    x <- as(x, "DataFrame")
    colnames(x)[colnames(x) == "gene"] <- "geneId"
    x <- x[, unique(c("geneId", colnames(x)))]
    keep <- grepl(pattern = genePattern, x = x[["geneId"]])
    x <- x[keep, , drop = FALSE]
    x <- x[
        order(x[["geneId"]], x[["sequence"]], x[["wormpep"]]), , drop = FALSE
    ]
    split(x, f = x[["geneId"]])
}

formals(peptides)[["version"]] <- versionArg
