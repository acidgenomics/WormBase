#' Orthologs
#'
#' @inheritParams params
#'
#' @return `tbl_df`.
#' @export
#'
#' @examples
#' x <- orthologs(progress = FALSE)
#' glimpse(x)
orthologs <- function(
    version = NULL,
    dir = ".",
    progress = FALSE
) {
    pblapply <- .pblapply(progress = progress)

    file <- .annotationFile(
        pattern = "orthologs",
        version = version,
        dir = dir
    )
    lines <- read_lines(
        file = unname(file),
        progress = FALSE
    )

    # Remove the comment lines.
    lines <- lines[!grepl("^#", lines)]

    lines <- lines %>%
        gsub("^=$", "\\|\\|", .) %>%
        paste(collapse = " ") %>%
        strsplit("\\|\\|") %>%
        unlist() %>%
        gsub("^ ", "", .)

    # Drop any lines that don't contain a gene identifier.
    lines <- lines %>%
        .[grepl(paste0("^", genePattern), .)]

    dflist <- pblapply(lines, function(x) {
        gene <- str_extract(x, genePattern)
        patterns <- c(
            homoSapiens = "ENSG\\d{11}",
            musMusculus = "ENSMUSG\\d{11}",
            drosophilaMelanogaster = "FBgn\\d{7}",
            danioRerio = "ENSDARG\\d{11}"
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
        tbl[["geneID"]] <- gene
        tbl
    })

    dflist %>%
        bind_rows() %>%
        select(!!sym("geneID"), everything())
}
