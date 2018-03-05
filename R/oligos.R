#' PCR Oligo Sequences
#'
#' @family FTP File Functions
#'
#' @importFrom dplyr arrange group_by mutate select
#' @importFrom readr read_tsv
#' @importFrom stats aggregate formula
#' @importFrom stringr str_extract
#' @importFrom tibble as_tibble
#'
#' @inheritParams general
#'
#' @return Gene [tibble].
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
        file = file,
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
