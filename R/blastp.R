#' Best BLASTP Hits
#'
#' @family FTP File Functions
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
    .assertFormalVersion(version)
    dir <- initializeDirectory(dir)
    if (is.null(version)) {
        version <- "current-production-release"
    }
    remoteDir = file.path(
        "ftp://ftp.wormbase.org",
        "pub",
        "wormbase",
        "releases",
        version,
        "species",
        "c_elegans",
        bioproject
    )
    file <- transmit(
        remoteDir = remoteDir,
        pattern = "best_blastp_hits"
    )
    assert_is_of_length(file, 1L)
    read_csv(file = as.character(file), col_names = FALSE) %>%
        .[, c(1L, 4L, 5L)] %>%
        set_colnames(c("wormpep", "peptide", "eValue")) %>%
        .[grepl("^ENSEMBL:ENSP\\d{11}$", .[["peptide"]]), , drop = FALSE] %>%
        .[order(.[["wormpep"]], .[["eValue"]]), ] %>%
        mutate(peptide = str_sub(.data[["peptide"]], 9L)) %>%
        group_by(!!sym("wormpep"))
}
