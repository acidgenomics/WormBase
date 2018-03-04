#' PCR Oligo Sequences
#'
#' @family Annotation File Functions
#'
#' @importFrom dplyr arrange group_by mutate select
#' @importFrom readr read_tsv
#' @importFrom stringr str_extract
#'
#' @inheritParams annotationFile
#'
#' @return [tibble] grouped by gene.
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
    df <-  suppressWarnings(read_tsv(
        file,
        col_names = c("oligo", "gene")
    ))
    df %>%
        mutate(gene = str_extract(.data[["gene"]], "WBGene\\d{8}")) %>%
        select(!!!syms(c("gene", "oligo"))) %>%
        group_by(!!sym("gene")) %>%
        arrange(!!sym("oligo"), .by_group = TRUE)
}
