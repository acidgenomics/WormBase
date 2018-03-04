#' Best BLASTP Hits
#'
#' @family Annotation File Functions
#'
#' @importFrom dplyr group_by mutate
#' @importFrom magrittr set_colnames
#' @importFrom readr read_csv
#' @importFrom stringr str_sub
#'
#' @inheritParams annotationFile
#'
#' @return [tibble] grouped by wormpep.
#' @export
#'
#' @examples
#' blastp() %>% glimpse()
blastp <- function(version = NULL, dir = ".") {
    file <- annotationFile(
        file = "best_blastp_hits",
        version = version,
        dir = dir
    )
    read_csv(file, col_names = FALSE) %>%
        .[, c(1L, 4L, 5L)] %>%
        set_colnames(c("wormpep", "peptide", "eValue")) %>%
        .[grepl("^ENSEMBL:ENSP\\d{11}$", .[["peptide"]]), , drop = FALSE] %>%
        .[order(.[["wormpep"]], .[["eValue"]]), ] %>%
        mutate(peptide = str_sub(.data[["peptide"]], 9L)) %>%
        group_by(!!sym("wormpep"))
}
