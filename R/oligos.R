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
#' oligos() %>% glimpse()
oligos <- function(version = NULL, dir = ".") {
    file <- .annotationFile(
        pattern = "pcr_product2gene",
        version = version,
        dir = dir
    )
    data <-  suppressWarnings(read_tsv(
        file = as.character(file),
        col_names = c("oligo", "gene"),
        progress = FALSE
    ))
    data[["gene"]] <- str_extract(data[["gene"]], "WBGene\\d{8}")
    aggregate(
        formula = formula("oligo~gene"),
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
