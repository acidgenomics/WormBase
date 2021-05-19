#' Gene Ontology terms
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
#' genes <- c("WBGene00000912", "WBGene00004804")
#' x <- geneOntology(genes)
#' print(x)
geneOntology <- function(genes) {
    assert(.allAreGenes(genes))
    list <- lapply(genes, function(gene) {
        query <- pasteURL(
            "widget",
            "gene",
            gene,
            "gene_ontology"
        )
        rest <- .rest(query)[["fields"]][["gene_ontology"]][["data"]]
        if (is.null(rest)) return(NULL)
        goTerms <- lapply(
            X = rest,
            FUN = function(process) {
                x <- lapply(
                    X = seq_along(process),
                    FUN = function(x) {
                        id <- process[[x]][["term_description"]][["id"]]
                        label <- process[[x]][["term_description"]][["label"]]
                        paste(id, label, sep = "~")
                    }
                )
                x <- unlist(x, recursive = FALSE, use.names = FALSE)
                x <- sort(unique(x))
                x
            }
        )
        goTerms <- CharacterList(goTerms)
        names(goTerms) <- camelCase(names(goTerms), strict = TRUE)
        goTerms <- goTerms[sort(names(goTerms))]
        goTerms
    })
    names(list) <- genes
    list <- List(list)
    list
}
