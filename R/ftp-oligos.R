#' PCR oligo sequences
#'
#' @note Updated 2019-07-27.
#' @export
#'
#' @inheritParams params
#'
#' @return `tbl_df`.
#'
#' @examples
#' ## WormBase FTP server must be accessible.
#' tryCatch(
#'     expr = oligos,
#'     error = function(e) e
#' )
oligos <- function(version = NULL) {
    file <- .annotationFile(pattern = "pcr_product2gene", version = version)
    ## `pcr_product2gene.txt` file is malformed and may produce warnings.
    suppressWarnings(
        data <- read_tsv(
            file = unname(file),
            col_names = c("oligo", "geneID"),
            progress = FALSE
        )
    )
    data %>%
        as_tibble() %>%
        mutate(
            !!sym("geneID") := str_extract(!!sym("geneID"), "WBGene\\d{8}")
        ) %>%
        aggregate(
            formula = formula("oligo~geneID"),
            data = .,
            FUN = function(x) {
                x %>%
                    unique() %>%
                    sort() %>%
                    list()
            }
        ) %>%
        as_tibble() %>%
        filter(grepl(pattern = genePattern, x = !!sym("geneID"))) %>%
        arrange(!!sym("geneID"))
}

formals(oligos)[["version"]] <- versionArg
