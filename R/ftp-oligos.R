#' PCR oligo sequences
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
#' x <- oligos()
#' print(x)
oligos <- function(version = NULL) {
    file <- .annotationFile(stem = "pcr_product2gene.txt.gz", version = version)
    ## File is malformed, so let's parse as lines.
    x <- import(file, format = "lines")
    x <- str_match(x, "^([^\t]+)\t(WBGene\\d{8})")
    x <- x[, c(2L:3L)]
    colnames(x) <- c("oligo", "geneId")
    agg <- aggregate(
        formula = formula("oligo~geneId"),
        data = x,
        FUN = function(x) {
            x <- unique(x)
            x <- sort(x)
            x <- list(x)
            x
        }
    )
    x <- CharacterList(agg[["oligo"]])
    names(x) <- agg[["geneId"]]
    keep <- grepl(pattern = .genePattern, x = names(x))
    x <- x[keep]
    x <- x[sort(names(x))]
    x
}

formals(oligos)[["version"]] <- .versionArg
