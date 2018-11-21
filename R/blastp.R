#' Best BLASTP Hits
#'
#' @inheritParams params
#'
#' @return `tbl_df`. Grouped by `wormpep` column.
#' @export
#'
#' @examples
#' x <- blastp()
#' glimpse(x)
blastp <- function(version = NULL, dir = ".") {
    file <- .assemblyFile(
        pattern = "best_blastp_hits",
        version = version,
        dir = dir
    )
    read_csv(
        file = as.character(file),
        col_names = FALSE,
        col_types = cols(),
        progress = FALSE
    ) %>%
        .[, c(1L, 4L, 5L)] %>%
        set_colnames(c("wormpep", "peptide", "eValue")) %>%
        .[grepl("^ENSEMBL:ENSP\\d{11}$", .[["peptide"]]), , drop = FALSE] %>%
        .[order(.[["wormpep"]], .[["eValue"]]), ] %>%
        mutate(peptide = str_sub(!!sym("peptide"), 9L)) %>%
        group_by(!!sym("wormpep"))
}
