#' Gene Ontology terms
#'
#' @note Updated 2020-01-03.
#' @export
#'
#' @inheritParams params
#' @inheritParams AcidRoxygen::params
#'
#' @return `DataFrame`.
#'
#' @examples
#' ## WormBase REST API must be accessible.
#' genes <- c("WBGene00000912", "WBGene00004804")
#' tryCatch(
#'     expr = geneOntology(genes),
#'     error = function(e) e
#' )
geneOntology <- function(
    genes,
    BPPARAM = BiocParallel::bpparam()  # nolint
) {
    assert(.allAreGenes(genes))
    x <- lapply(genes, function(gene) {
        query <- paste(
            "widget",
            "gene",
            gene,
            "gene_ontology",
            sep = "/"
        )
        data <- .rest(query)[["fields"]][["gene_ontology"]][["data"]]
        if (is.null(data)) return(NULL)
        goTerms <- bplapply(
            X = data,
            FUN = function(process) {
                x <- lapply(
                    X = seq_along(process),
                    FUN = function(x) {
                        id <- process[[x]][["term_description"]][["id"]]
                        label <- process[[x]][["term_description"]][["label"]]
                        paste(id, label, sep = "~")
                    }
                )
                x <- unlist(x)
                x <- sort(unique(x))
                x
            },
            BPPARAM = BPPARAM
        )
        x <- data.frame(do.call(cbind, lapply(goTerms, list)))
        x[["geneId"]] <- gene
        x
    })
    x <- Filter(Negate(is.null), x)
    if (!hasLength(x)) return(NULL)
    x <- rbindlist(x, fill = TRUE)
    x <- as(x, "DataFrame")
    x <- camelCase(x, strict = TRUE)
    x <- x[, unique(c("geneId", sort(colnames(x))))]
    x
}
