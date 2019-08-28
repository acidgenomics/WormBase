#' Peptides
#'
#' @note Updated 2019-08-28.
#' @export
#'
#' @inheritParams params
#'
#' @return `SplitDataFrameList`.
#' Split by `geneID` column.
#'
#' @examples
#' ## WormBase FTP server must be accessible.
#' tryCatch(
#'     expr = peptides(),
#'     error = function(e) e
#' )
peptides <- function(
    version = NULL,
    BPPARAM = BiocParallel::bpparam()
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
    message("Processing peptides.")
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
            DataFrame(t(out))
        },
        BPPARAM = BPPARAM
    )
    dflist %>%
        bind_rows() %>%
        rename(geneID = !!sym("gene")) %>%
        select(!!sym("geneID"), everything()) %>%
        filter(grepl(pattern = genePattern, x = !!sym("geneID"))) %>%
        group_by(!!sym("geneID")) %>%
        arrange(!!!syms(c("sequence", "wormpep")), .by_group = TRUE)
}

formals(peptides)[["version"]] <- versionArg
