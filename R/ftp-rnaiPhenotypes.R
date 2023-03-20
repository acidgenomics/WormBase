#' RNAi phenotypes
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
#' x <- rnaiPhenotypes()
#' print(x)
rnaiPhenotypes <- function(release = NULL) {
    ## Starting with WS280, moved from ontology to annotation on FTP server.
    where <- "annotation"
    if (!is.null(release)) {
        releaseInt <- as.integer(sub(
            pattern = "^WS",
            replacement = "",
            x = release
        ))
        if (releaseInt < 280L) {
            where <- "ontology"
        }
    }
    file <- switch(
        EXPR = where,
        "annotation" = {
            ## Starting with WS280.
            .annotationFile(
                stem = "rnai_phenotypes_quick.wb.gz",
                release = release
            )
        },
        "ontology" = {
            ## Ending with WS279.
            .ontologyFile(
                stem = "rnai_phenotypes_quick",
                release = release
            )
        }
    )
    x <- import(
        con = file,
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

formals(rnaiPhenotypes)[["release"]] <- .releaseArg
