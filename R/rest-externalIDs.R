#' External identifiers
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
#'     expr = externalIDs(genes),
#'     error = function(e) e
#' )
externalIDs <- function(
    genes,
    BPPARAM = BiocParallel::bpparam()  # nolint
) {
    assert(.allAreGenes(genes))
    x <- lapply(genes, function(gene) {
        query <- paste(
            "widget",
            "gene",
            gene,
            "external_links",
            sep = "/"
        )
        data <- .rest(query)[["fields"]][["xrefs"]][["data"]]
        if (is.null(data)) return(NULL)
        xrefs <- bplapply(
            X = data,
            FUN = function(x) {
                x <- unlist(x[[1L]][[1L]])
                x <- sort(unique(x))
                x
            },
            BPPARAM = BPPARAM
        )
        x <- data.frame(do.call(cbind, lapply(xrefs, list)))
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
