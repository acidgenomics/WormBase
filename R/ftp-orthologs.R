#' Orthologs
#'
#' @note Updated 2023-09-25.
#' @export
#'
#' @inheritParams params
#' @inheritParams AcidRoxygen::params
#'
#' @return `List`.
#'
#' @examples
#' x <- orthologs()
#' print(x)
orthologs <- function(release = NULL) {
    file <- .annotationFile(stem = "orthologs.txt.gz", release = release)
    x <- import(file, format = "lines", comment = "#")
    x <- gsub("^=$", "\\|\\|", x)
    x <- paste(x, collapse = " ")
    x <- strsplit(x, "\\|\\|")[[1L]]
    x <- gsub("^ ", "", x)
    x <- x[grepl(paste0("^", .genePattern), x)]
    genes <- strMatch(x = x, pattern = .genePattern, fixed = FALSE)[, 1L]
    assert(
        identical(length(genes), length(x)),
        allAreMatchingRegex(x = genes, pattern = .genePattern)
    )
    patterns <- c(
        "danioRerio" = "\\bENSDARG\\d{11}\\b",
        "drosophilaMelanogaster" = "\\bFBgn\\d{7}\\b",
        "homoSapiens" = "\\bENSG\\d{11}\\b",
        "musMusculus" = "\\bENSMUSG\\d{11}\\b"
    )
    x <- mclapply(
        X = x,
        patterns = patterns,
        FUN = function(x, patterns) {
            Map(
                x = x,
                pattern = patterns,
                f = function(x, pattern) {
                    strMatch(x = x, pattern = pattern, fixed = FALSE)[1L, 1L]
                },
                USE.NAMES = FALSE
            )
        }
    )
    x <- lapply(X = x, FUN = `names<-`, value = names(patterns))
    x <- List(x)
    names(x) <- genes
    keep <- grepl(pattern = .genePattern, x = names(x))
    x <- x[keep]
    x <- x[sort(names(x))]
    x
}

formals(orthologs)[["release"]] <- .releaseArg
