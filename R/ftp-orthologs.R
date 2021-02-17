#' Orthologs
#'
#' @note Updated 2021-02-17.
#' @export
#'
#' @inheritParams params
#' @inheritParams AcidRoxygen::params
#'
#' @return `DataFrame`.
#'
#' @examples
#' ## WormBase FTP server must be accessible.
#' tryCatch(
#'     expr = orthologs(),
#'     error = function(e) e
#' )
orthologs <- function(
    version = NULL,
    BPPARAM = BiocParallel::bpparam()  # nolint
) {
    file <- .annotationFile(pattern = "orthologs", version = version)
    x <- import(file, format = "lines")
    ## Remove the comment lines.
    x <- x[!grepl("^#", x)]
    x <- gsub("^=$", "\\|\\|", x)
    x <- paste(x, collapse = " ")
    x <- strsplit(x, "\\|\\|")
    x <- unlist(x, recursive = FALSE, use.names = FALSE)
    x <- gsub("^ ", "", x)
    ## Drop any lines that don't contain a gene identifier.
    x <- x[grepl(paste0("^", .genePattern), x)]
    alert("Processing orthologs.")
    x <- bplapply(
        X = x,
        FUN = function(x) {
            gene <- str_extract(x, .genePattern)
            patterns <- c(
                homoSapiens = "ENSG\\d{11}",
                musMusculus = "ENSMUSG\\d{11}",
                drosophilaMelanogaster = "FBgn\\d{7}",
                danioRerio = "ENSDARG\\d{11}"
            )
            orthologs <- mapply(
                FUN = function(x, pattern) {
                    pattern <- paste0("\\b", pattern, "\\b")
                    x <- str_extract_all(x, pattern)
                    x <- unlist(x)
                    x <- unique(x)
                    x <- sort(x)
                    if (!length(x)) {
                        x <- NULL
                    }
                    x
                },
                pattern = patterns,
                MoreArgs = list(x = x),
                SIMPLIFY = FALSE,
                USE.NAMES = FALSE
            )
            names(orthologs) <- names(patterns)
            x <- lapply(orthologs, list)
            x <- DataFrame(do.call(cbind, x))
            x[["geneId"]] <- gene
            x
        },
        BPPARAM = BPPARAM
    )
    x <- DataFrameList(x)
    x <- unlist(x, recursive = FALSE, use.names = FALSE)
    keep <- grepl(pattern = .genePattern, x = x[["geneId"]])
    x <- x[keep, , drop = FALSE]
    x <- x[order(x[["geneId"]]), , drop = FALSE]
    x <- x[, unique(c("geneId", sort(colnames(x))))]
    x
}

formals(orthologs)[["version"]] <- .versionArg
