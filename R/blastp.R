#' Best BLASTP hits
#'
#' @inheritParams params
#'
#' @return `tbl_df`. Grouped by `wormpep` column.
#' @export
#'
#' @examples
#' x <- blastp()
#' glimpse(x)
blastp <- function(version = NULL) {
    file <- .assemblyFile(
        pattern = "best_blastp_hits",
        version = version
    )
    import(file = unname(file), colnames = FALSE) %>%
        as_tibble() %>%
        .[, c(1L, 4L, 5L)] %>%
        set_colnames(c("wormpep", "peptide", "eValue")) %>%
        .[grepl("^ENSEMBL:ENSP\\d{11}$", .[["peptide"]]), , drop = FALSE] %>%
        .[order(.[["wormpep"]], .[["eValue"]]), ] %>%
        mutate(
            !!sym("peptide") := str_sub(!!sym("peptide"), 9L),
            !!sym("eValue") := as.numeric(!!sym("eValue"))
        ) %>%
        group_by(!!sym("wormpep"))
}
