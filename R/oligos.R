#' PCR Oligo Sequences
#'
#' @family Annotation File Functions
#'
#' @importFrom dplyr arrange group_by mutate select
#' @importFrom readr read_tsv
#' @importFrom stats aggregate
#' @importFrom stringr str_extract
#' @importFrom tibble as_tibble
#'
#' @inheritParams annotationFile
#'
#' @return Gene [tibble].
#' @export
#'
#' @examples
#' oligos() %>% glimpse()
oligos <- function(version = NULL, dir = ".") {
    file <- annotationFile(
        file = "pcr_product2gene",
        version = version,
        dir = dir
    )
    data <-  suppressWarnings(read_tsv(
        file,
        col_names = c("oligo", "gene")
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
