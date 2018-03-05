#' Peptides
#'
#' @family FTP File Functions
#'
#' @importFrom basejump transmit
#' @importFrom dplyr arrange bind_rows everything group_by select
#' @importFrom fs path
#' @importFrom parallel mclapply
#' @importFrom stringr str_match str_match_all
#' @importFrom utils untar
#'
#' @inheritParams general
#'
#' @return [tibble] grouped by gene.
#' @export
#'
#' @examples
#' peptides() %>% glimpse()
peptides <- function(version = NULL, dir = ".") {
    file <- .assemblyFile(
        pattern = "wormpep_package",
        version = version,
        dir = dir
    )
    file <- as.character(file)

    # Grep the verion number
    versionNumber <- str_extract(file, "WS\\d{3}") %>%
        gsub("^WS", "", .)

    # Extract the individual table
    wormpepTable <- paste0("wormpep.table", versionNumber)
    untar(
        tarfile = file,
        files = wormpepTable,
        exdir = dir
    )

    lines <- read_lines(path(dir, wormpepTable), progress = FALSE)
    dflist <- mclapply(lines, function(line) {
        # Attempt to match quoted values first (e.g. product)
        keyPattern <- "([a-z]+)=(\"[^\"]+\"|[^\\s]+)"
        keyPairs <- str_match_all(line, keyPattern) %>%
            .[[1L]] %>%
            # Remove any escaped quotes
            gsub('"', '', .)
        x <- c(keyPairs[, 3L])
        names(x) <- keyPairs[, 2L]
        sequence <- str_match(line, "^>([A-Za-z0-9\\.]+)") %>%
            .[[2]]
        c("sequence" = sequence, x) %>%
            t() %>%
            as_tibble()
    })
    dflist %>%
        bind_rows() %>%
        select(!!sym("gene"), everything()) %>%
        group_by(!!sym("gene")) %>%
        arrange(!!!syms(c("sequence", "wormpep")), .by_group = TRUE)
}
