#' PCR Oligo Sequences
#'
#' @family FTP File Functions
#'
#' @inheritParams general
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
    data <-  suppressWarnings(read_tsv(
        file = as.character(file),
        col_names = c("oligo", "geneID"),
        progress = FALSE
    ))
    data[["geneID"]] <- str_extract(data[["geneID"]], "WBGene\\d{8}")
    aggregate(
        formula = formula("oligo~geneID"),
        data = data,
        FUN = function(x) {
            x %>%
                unique() %>%
                sort() %>%
                list()
        }
    ) %>%
        as_tibble()
}
