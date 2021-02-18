#' RNAi phenotypes
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
#' x <- rnaiPhenotypes()
#' print(x)
rnaiPhenotypes <- function(version = NULL) {
    file <- .ontologyFile(stem = "rnai_phenotypes_quick", version = version)
    x <- import(
        file = file,
        format = "tsv",
        colnames = c("geneId", "sequence", "rnaiPhenotypes")
    )
    genes <- x[["geneId"]]
    x <- strsplit(x[["rnaiPhenotypes"]], ", ")
    x <- CharacterList(x)
    names(x) <- genes
    keep <- grepl(pattern = .genePattern, x = names(x))
    x <- x[keep]
    x <- x[sort(names(x))]
    x <- sort(unique(x))
    x
}

formals(rnaiPhenotypes)[["version"]] <- .versionArg
