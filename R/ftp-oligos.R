#' PCR oligo sequences
#'
#' @note Updated 2022-06-08.
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
oligos <- function(release = NULL) {
    file <- .annotationFile(stem = "pcr_product2gene.txt.gz", release = release)
    ## File is malformed, so let's parse as lines.
    x <- import(file, format = "lines")
    x <- stri_match_first_regex(str = x, pattern = "^([^\t]+)\t(WBGene\\d{8})")
    x <- x[, c(2L:3L)]
    colnames(x) <- c("oligo", "geneId")
    agg <- aggregate(
        formula = formula("oligo~geneId"),
        data = x,
        FUN = list
    )
    x <- CharacterList(agg[["oligo"]])
    names(x) <- agg[["geneId"]]
    keep <- grepl(pattern = .genePattern, x = names(x))
    x <- x[keep]
    x <- x[sort(names(x))]
    x <- sort(unique(x))
    x
}

formals(oligos)[["release"]] <- .releaseArg
