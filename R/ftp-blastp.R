#' Best BLASTP hits
#'
#' @note Updated 2019-07-27.
#' @export
#'
#' @inheritParams params
#'
#' @return `tbl_df`. Grouped by `wormpep` column.
#'
#' @examples
#' ## WormBase FTP server must be accessible.
#' if (!is.null(curl::nslookup("ftp.wormbase.org"))) {
#'     x <- blastp()
#'     glimpse(x)
#' }
blastp <- function(version = NULL) {
    file <- .assemblyFile(
        pattern = "best_blastp_hits",
        version = version
    )
    file %>%
        unname() %>%
        import(colnames = FALSE) %>%
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

formals(blastp)[["version"]] <- versionArg
