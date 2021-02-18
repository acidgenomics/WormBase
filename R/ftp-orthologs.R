#' Orthologs
#'
#' @note Updated 2021-02-17.
#' @export
#'
#' @inheritParams params
#' @inheritParams AcidRoxygen::params
#'
#' @return `DataFrame`.
#'
#' @examples
#' ## WormBase FTP server must be accessible.
#' tryCatch(
#'     expr = orthologs(),
#'     error = function(e) e
#' )
orthologs <- function(version = NULL) {
    file <- .annotationFile(stem = "orthologs.txt.gz", version = version)
    x <- import(file, format = "lines", comment = "#")
    x <- gsub("^=$", "\\|\\|", x)
    x <- paste(x, collapse = " ")
    x <- strsplit(x, "\\|\\|")[[1L]]
    x <- gsub("^ ", "", x)
    x <- x[grepl(paste0("^", .genePattern), x)]
    alert("Processing orthologs.")
    genes <- str_extract(string = x, pattern = .genePattern)
    assert(identical(length(genes), length(x)))
    orthologs <- lapply(
        X = x,
        FUN = function(x, patterns) {
            l <- mapply(
                FUN = function(x, pattern) {
                    x <- str_extract_all(string = x, pattern = pattern)[[1L]]
                    x <- unique(x)
                    x <- sort(x)
                    x
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
    orthologs <- CharacterList(orthologs)
    x <- DataFrame(
        "geneId" = genes,
        "orthologs" = orthologs
    )
    x <- x[order(x[["geneId"]]), , drop = FALSE]
    x
}

formals(orthologs)[["version"]] <- .versionArg
