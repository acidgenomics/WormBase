#' External identifiers
#'
#' @note Updated 2021-02-18.
#' @export
#'
#' @inheritParams params
#' @inheritParams AcidRoxygen::params
#'
#' @return `List`.
#'
#' @examples
#' ## WormBase REST API must be accessible.
#' genes <- c("WBGene00000912", "WBGene00004804")
#' tryCatch(
#'     expr = externalIDs(genes),
#'     error = function(e) e
#' )
externalIDs <- function(genes) {
    assert(.allAreGenes(genes))
    l <- lapply(genes, function(gene) {
        q <- pasteURL(
            "widget",
            "gene",
            gene,
            "external_links"
        )
        x <- .rest(q)[["fields"]][["xrefs"]][["data"]]
        if (is.null(x)) return(NULL)
        x <- lapply(
            X = x,
            FUN = function(x) {
                x <- x[["gene"]][["ids"]]
                x <- unlist(x, recursive = FALSE, use.names = FALSE)
                x
            }
        )
        x <- Filter(Negate(is.null), x)
        x <- CharacterList(x)
        x <- sort(unique(x))
        x <- x[sort(names(x))]
        x
    })
    l <- List(l)
    names(l) <- genes
    l
}
