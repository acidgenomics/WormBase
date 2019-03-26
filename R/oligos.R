#' PCR oligo sequences
#'
#' @inheritParams params
#'
#' @return `tbl_df`.
#' @export
#'
#' @examples
#' x <- oligos()
#' glimpse(x)
oligos <- function(version = NULL) {
    file <- .annotationFile(pattern = "pcr_product2gene", version = version)
    # `pcr_product2gene.txt` file is malformed and may produce warnings.
    suppressWarnings(
        data <- read_tsv(
            file = file,
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
