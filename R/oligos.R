#' PCR Oligo Sequences
#'
#' @inheritParams params
#'
#' @return `tbl_df`.
#' @export
#'
#' @examples
#' x <- oligos()
#' glimpse(x)
oligos <- function(version = NULL, dir = ".") {
    file <- .annotationFile(
        pattern = "pcr_product2gene",
        version = version,
        dir = dir
    )
    # `pcr_product2gene.txt` file is malformed and may produce warnings.
    suppressWarnings(
        data <- read_tsv(
            file = unname(file),
            col_names = c("oligo", "geneID"),
            progress = FALSE
        )
    )
    data %>%
        mutate(geneID = str_extract(!!sym("geneID"), "WBGene\\d{8}")) %>%
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
        as_tibble()
}
