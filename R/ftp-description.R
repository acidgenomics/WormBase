#' Gene functional descriptions
#'
#' @note As of WS269 release, some non-N2 gene IDs are included in the flat
#'   files available on the WormBase FTP server. These annotations are removed
#'   from the return here, using grep matching to return only `WBGene` entries.
#'
#' @note This file is malformed on the WormBase FTP server for WS270 and WS271
#'   releases.
#'
#' @note Updated 2021-02-18.
#' @export
#'
#' @inheritParams params
#' @inheritParams AcidRoxygen::params
#'
#' @return `DataFrame`.
#'
#' @examples
#' x <- description()
#' print(x)
description <- function(release = NULL) {
    file <- .annotationFile(
        stem = "functional_descriptions.txt.gz",
        release = release
    )
    ## Process file by reading lines in directly.
    x <- import(file, format = "lines", comment = "#")
    ## Genes are separated by a line containing `=`.
    x <- gsub(pattern = "^=$", replacement = "\\|\\|", x = x)
    ## Add a tab delimiter before our keys of interest.
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
    x <- strsplit(x, "\\|\\|")[[1L]]
    ## Clean up spaces and tabs.
    x <- gsub("  ", " ", x)
    x <- gsub("^ ", "", x)
    x <- gsub(" $", "", x)
    x <- gsub(" \t", "\t", x)
    x <- gsub("\t ", "\t", x)
    ## Now split by the tab delimiters.
    x <- strsplit(x, "\t")
    x <- CharacterList(x)
    ## Before we process the list, remove non-N2 annotations.
    ## These were added in WS269.
    ## For example, drop these: "PRJEB28388_chrIII_pilon.g6684".
    keep <- bapply(
        X = x,
        FUN = function(x) {
            grepl(pattern = .genePattern, x = x[[1L]])
        }
    )
    if (!any(keep)) {
        .invalidFTPFile(file)
    }
    x <- x[keep]
    x <- lapply(
        X = x,
        FUN = function(x) {
            ## This step checks for columns such as "Concise description:".
            pattern <- "^([A-Za-z[:space:]]+)\\:"
            names <- str_match(x, pattern = pattern)[, 2L]
            ## The first 3 columns won't match the pattern, so assign manually.
            names[seq_len(3L)] <- c("geneId", "geneName", "sequence")
            names(x) <- names
            ## Remove the key prefix (e.g. "Concise description:").
            x <- gsub(paste0(pattern, " "), "", x)
            ## Ensure the user uses the values from `geneIDs()` return instead.
            keep <- setdiff(names(x), c("geneName", "sequence"))
            x <- x[keep]
            x
        }
    )
    assert(is(x, "list"))
    x <- unlistToDataFrame(x = lapply(X = x, FUN = t))
    colnames(x) <- camelCase(colnames(x), strict = TRUE)
    assert(
        is(x, "DataFrame"),
        isSubset("geneId", colnames(x))
    )
    x <- sanitizeNA(x)
    x <- removeNA(x)
    x <- x[order(x[["geneId"]]), , drop = FALSE]
    rownames(x) <- x[["geneId"]]
    x
}

formals(description)[["release"]] <- .releaseArg
