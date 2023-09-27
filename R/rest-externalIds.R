#' External identifiers
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
#' genes <- c("WBGene00000912", "WBGene00004804")
#' x <- externalIds(genes)
#' print(x)
#' print(x[[1L]])
externalIds <- function(genes) {
    assert(.allAreGenes(genes))
    list <- lapply(genes, function(gene) {
        query <- paste(
            "widget",
            "gene",
            gene,
            "external_links",
            sep = "/"
        )
        rest <- .rest(query)[["fields"]][["xrefs"]][["data"]]
        if (is.null(rest)) {
            return(NULL)
        }
        x <- lapply(
            X = rest,
            FUN = function(x) {
                x <- x[["gene"]][["ids"]]
                x <- unlist(x, recursive = FALSE, use.names = FALSE)
                x
            }
        )
        x <- Filter(Negate(is.null), x)
        x <- CharacterList(x)
        x <- x[sort(names(x))]
        x <- sort(unique(x))
        x
    })
    list <- List(list)
    names(list) <- genes
    list
}
