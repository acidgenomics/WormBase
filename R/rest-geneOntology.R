## FIXME The REST API is no longer working as expected.
## Error in curl::curl_fetch_memory(url, handle = handle) :
## Empty reply from server



#' Gene Ontology terms
#'
#' @note Updated 2019-08-29.
#' @export
#'
#' @inheritParams params
#' @inheritParams acidroxygen::params
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
        x[["geneID"]] <- gene
        x
    })
    x <- Filter(Negate(is.null), x)
    if (!hasLength(x)) return(NULL)
    x <- rbindlist(x, fill = TRUE)
    x <- as(x, "DataFrame")
    x <- camelCase(x)
    x <- x[, unique(c("geneID", sort(colnames(x))))]
    x
}
