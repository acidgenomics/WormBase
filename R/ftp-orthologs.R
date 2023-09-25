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
    x <- gsub(pattern = "^=$", replacement = "\\|\\|", x = x)
    x <- paste(x, collapse = " ")
    x <- strsplit(x, split = "||", fixed = TRUE)[[1L]]
    x <- gsub(pattern = "^ ", replacement = "", x = x)
    x <- x[grepl(pattern = paste0("^", .genePattern), x = x)]
    genes <- strExtract(x = x, pattern = .genePattern, fixed = FALSE)
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
                f = strExtract,
                pattern = patterns,
                MoreArgs = list("x" = x),
                USE.NAMES = FALSE
            )
        }
    )
    x <- lapply(X = x, FUN = `names<-`, value = names(patterns))
    x <- List(x)
    names(x) <- genes
    x <- x[sort(names(x))]
    x
}

formals(orthologs)[["release"]] <- .releaseArg
