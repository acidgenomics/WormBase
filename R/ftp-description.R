#' Gene functional descriptions
#'
#' @note As of WS269 release, some non-N2 gene IDs are included in the flat
#' files available on the WormBase FTP server. These annotations are removed
#' from the return here, using grep matching to return only `WBGene` entries.
#'
#' @note This file is malformed on the WormBase FTP server for WS270 and WS271
#' releases.
#'
#' @note Updated 2023-09-25.
#' @export
#'
#' @inheritParams params
#' @inheritParams AcidRoxygen::params
#'
#' @return `DFrame`.
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
    x <- sub(pattern = "^=$", replacement = "||", x = x)
    ## Add a tab delimiter before our keys of interest.
    x <- sub(
        pattern = paste0(
            "(Concise|Provisional|Detailed|Automated|Gene class)",
            " description\\:"
        ),
        replacement = "\t\\1 description:",
        x = x
    )
    ## Now collapse to a single line and split by the gene separator (`||`).
    x <- paste(x, collapse = " ")
    x <- strsplit(x, split = "||", fixed = TRUE)[[1L]]
    ## Clean up spaces and tabs.
    x <- sub(pattern = "^ ", replacement = "", x = x)
    x <- sub(pattern = " $", replacement = "", x = x)
    x <- gsub(pattern = "  ", replacement = " ", x = x)
    x <- gsub(pattern = " \t", replacement = "\t", x = x)
    x <- gsub(pattern = "\t ", replacement = "\t", x = x)
    ## Now split by the tab delimiters.
    x <- strsplit(x, split = "\t")
    assert(all(lengths(x) == 6L))
    x <- CharacterList(x)
    ## Before we process the list, remove non-N2 annotations. Added in WS269.
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
    x <- mclapply(
        X = x,
        FUN = function(x) {
            x[[1L]] <- paste0("geneId: ", x[[1L]])
            x[[2L]] <- paste0("geneName: ", x[[2L]])
            x[[3L]] <- paste0("sequence: ", x[[3L]])
            ## e.g. WBGene00000160 gene class description is empty.
            x <- sub(pattern = ":$", replacement = ": not known", x = x)
            x <- strSplit(x = x, split = ": ", fixed = TRUE, n = 2L)
            out <- x[, 2L]
            names(out) <- x[, 1L]
            ## Ensure the user uses the values from `geneIds()` return instead.
            keep <- setdiff(names(out), c("geneName", "sequence"))
            out <- out[keep]
            out
        }
    )
    assert(all(lengths(x) == 4L))
    x <- rbindToDataFrame(x)
    colnames(x) <- camelCase(colnames(x), strict = TRUE)
    assert(
        is(x, "DFrame"),
        isSubset("geneId", colnames(x))
    )
    x <- sanitizeNa(x)
    x <- removeNa(x)
    x <- x[order(x[["geneId"]]), , drop = FALSE]
    rownames(x) <- x[["geneId"]]
    x
}

formals(description)[["release"]] <- .releaseArg
