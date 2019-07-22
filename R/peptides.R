#' Peptides
#'
#' @inheritParams params
#'
#' @return `tbl_df`. Grouped by `gene` column.
#' @export
#'
#' @examples
#' x <- peptides()
#' glimpse(x)
peptides <- function(version = NULL, progress = FALSE) {
    pblapply <- .pblapply(progress = progress)
    file <- .assemblyFile(pattern = "wormpep_package", version = version)
    dir <- tempdir()

    ## Grep the verion number.
    versionNumber <- file %>%
        str_extract("WS\\d{3}") %>%
        gsub("^WS", "", .)

    ## Extract the individual table.
    wormpepTable <- paste0("wormpep.table", versionNumber)
    untar(
        tarfile = file,
        files = wormpepTable,
        exdir = dir
    )

    lines <- read_lines(file.path(dir, wormpepTable), progress = FALSE)

    message("Processing peptides...")
    dflist <- pblapply(lines, function(line) {
        ## Attempt to match quoted values first (e.g. product).
        keyPattern <- "([a-z]+)=(\"[^\"]+\"|[^\\s]+)"
        keyPairs <- str_match_all(line, keyPattern) %>%
            .[[1L]] %>%
            ## Remove any escaped quotes.
            gsub("\"", "", .)
        x <- c(keyPairs[, 3L])
        names(x) <- keyPairs[, 2L]
        sequence <- str_match(line, "^>([A-Za-z0-9\\.]+)") %>%
            .[[2L]]
        c(sequence = sequence, x) %>%
            t() %>%
            as_tibble()
    })
    dflist %>%
        bind_rows() %>%
        rename(geneID = !!sym("gene")) %>%
        select(!!sym("geneID"), everything()) %>%
        filter(grepl(pattern = genePattern, x = !!sym("geneID"))) %>%
        group_by(!!sym("geneID")) %>%
        arrange(!!!syms(c("sequence", "wormpep")), .by_group = TRUE)
}
