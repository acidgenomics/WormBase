#' Gene functional descriptions
#'
#' @note As of WS269 release, some non-N2 gene IDs are included in the flat
#'   files available on the WormBase FTP server. These annotations are removed
#'   from the return here, using grep matching to return only `WBGene` entries.
#'
#' @note This file is currently malformed on the WormBase FTP server for WS270
#'   and WS271 releases.
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
#' ## Currently failing for WS270, WS271 releases.
#' tryCatch(
#'     expr = description(version = "WS269"),
#'     error = function(e) e
#' )
description <- function(
    version = NULL,
    BPPARAM = BiocParallel::bpparam()  # nolint
) {
    file <- .annotationFile(
        pattern = "functional_descriptions",
        version = version
    )
    ## Process file by reading lines in directly.
    x <- import(file, format = "lines")
    ## The first 3 lines contain comments.
    x <- tail(x, n = -3L)
    ## Genes are separated by a line containing `=`.
    x <- gsub(pattern = "^=$", replacement = "\\|\\|", x = x)
    ## Add a tab delimiter before our keys of interest:
    ## - Concise description
    ## - Provisional description
    ## - Detailed description
    ## - Automated description
    ## - Gene class description
    x <- gsub(
        pattern = paste0(
            "(Concise|Provisional|Detailed|Automated|Gene class)",
            " description\\:"
        ),
        replacement = "\t\\1 description:",
        x = x
    )
    ## Now collapse to a single line and split by the gene separator (`||`).
    x <- paste(x, collapse = " ")
    x <- strsplit(x, "\\|\\|")
    x <- unlist(x)
    ## Clean up spaces and tabs.
    x <- gsub("  ", " ", x)
    x <- gsub("^ ", "", x)
    x <- gsub(" $", "", x)
    x <- gsub(" \t", "\t", x)
    x <- gsub("\t ", "\t", x)
    ## Now split by the tab delimiters.
    x <- strsplit(x, "\t")
    ## Before we process the list, remove non-N2 annotations.
    ## These were added in WS269.
    ## For example, drop these: "PRJEB28388_chrIII_pilon.g6684".
    keep <- bapply(
        X = x,
        FUN = function(x) {
            grepl(pattern = genePattern, x = x[[1L]])
        }
    )
    if (!any(keep)) {
        .invalidFTPFile(file)
    }
    x <- x[keep]
    ## Parallelize the processing steps here to speed up the return.
    message("Processing functional descriptions.")
    x <- bplapply(
        X = x,
        FUN = function(x) {
            ## This step checks for columns such as "Concise description:".
            pattern <- "^([A-Za-z[:space:]]+)\\:"
            names <- str_match(x, pattern = pattern)[, 2L]
            ## The first 3 columns won't match the pattern, so assign manually.
            names[seq_len(3L)] <- c("geneID", "geneName", "sequence")
            names <- camelCase(names)
            ## Remove the key prefix (e.g. "Concise description:").
            x <- gsub(paste0(pattern, " "), "", x)
            x <- t(x)
            x <- as.data.frame(x)
            colnames(x) <- names
            ## Ensure the user uses the values from `geneIDs()` return instead.
            keep <- setdiff(colnames(x), c("geneName", "sequence"))
            x <- x[, keep, drop = FALSE]
            x
        },
        BPPARAM = BPPARAM
    )
    x <- rbindlist(x, fill = TRUE)
    x <- as(x, "DataFrame")
    x <- camelCase(x)
    x <- sanitizeNA(x)
    x <- removeNA(x)
    x <- x[order(x[["geneID"]]), , drop = FALSE]
    x
}

formals(description)[["version"]] <- versionArg
