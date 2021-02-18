#' Orthologs
#'
#' @note Updated 2021-02-18.
#' @export
#'
#' @inheritParams params
#' @inheritParams AcidRoxygen::params
#'
#' @return `CharacterList`.
#'
#' @examples
#' x <- orthologs()
#' print(x)
orthologs <- function(version = NULL) {
    file <- .annotationFile(stem = "orthologs.txt.gz", version = version)
    x <- import(file, format = "lines", comment = "#")
    x <- gsub("^=$", "\\|\\|", x)
    x <- paste(x, collapse = " ")
    x <- strsplit(x, "\\|\\|")[[1L]]
    x <- gsub("^ ", "", x)
    x <- x[grepl(paste0("^", .genePattern), x)]
    genes <- str_extract(string = x, pattern = .genePattern)
    assert(identical(length(genes), length(x)))
    l <- lapply(
        X = x,
        FUN = function(x, patterns) {
            l <- mapply(
                FUN = function(x, pattern) {
                    str_extract_all(string = x, pattern = pattern)[[1L]]
                },
                pattern = patterns,
                MoreArgs = list(x = x),
                SIMPLIFY = FALSE,
                USE.NAMES = FALSE
            )
            names(l) <- names(patterns)
            l
        },
        patterns = c(
            "danioRerio" = "\\bENSDARG\\d{11}\\b",
            "drosophilaMelanogaster" = "\\bFBgn\\d{7}\\b",
            "homoSapiens" = "\\bENSG\\d{11}\\b",
            "musMusculus" = "\\bENSMUSG\\d{11}\\b"
        )
    )
    l <- CharacterList(l)
    names(l) <- genes
    l <- sort(unique(l))
    l
}

formals(orthologs)[["version"]] <- .versionArg
