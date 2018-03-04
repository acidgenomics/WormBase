#' Orthologs
#'
#' @family Annotation File Functions
#'
#' @importFrom BiocParallel bplapply
#' @importFrom readr read_file read_tsv
#' @importFrom stringr str_extract_all
#'
#' @inheritParams annotationFile
#'
#' @return [tibble].
#' @export
#'
#' @examples
#'  %>% glimpse()
orthologs <- function(version = NULL, dir = ".") {
    file <- annotationFile(
        file = "orthologs",
        version = version,
        dir = dir
    )
    lines <- read_lines(file)

    # Remove the comment lines
    lines <- lines[!grepl("^#", lines)]

    lines <- lines %>%
        gsub("^=$", "\\|\\|", .) %>%
        paste(collapse = " ") %>%
        strsplit("\\|\\|") %>%
        unlist() %>%
        gsub("^ ", "", .)

    # Drop any lines that don't contain a gene identifier
    lines <- lines %>%
        .[grepl(paste0("^", genePattern), .)]

    dflist <- bplapply(lines, function(x) {
        gene <- str_extract(x, genePattern)
        patterns <- c(
            "homoSapiens" = "ENSG\\d{11}",
            "musMusculus" = "ENSMUSG\\d{11}",
            "drosophilaMelanogaster" = "FBgn\\d{7}",
            "danioRerio" = "ENSDARG\\d{11}"
        )
        orthologs <- mapply(
            FUN = function(string, pattern) {
                x <- str_extract_all(
                    string = string,
                    pattern = paste0("\\b", pattern, "\\b")
                ) %>%
                    unlist() %>%
                    unique() %>%
                    sort()
                if (!length(x)) {
                    x <- NULL
                }
                x
            },
            pattern = patterns,
            MoreArgs = list(string = x),
            SIMPLIFY = FALSE,
            USE.NAMES = TRUE
        )
        tbl <- lapply(orthologs, list) %>%
            as_tibble()
        tbl[["gene"]] <- gene
        tbl
    })

    dflist %>%
        bind_rows() %>%
        .[, c("gene", setdiff(colnames(.), "gene"))]
}
