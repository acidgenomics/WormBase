#' Peptide to Gene
#'
#' @importFrom basejump transmit
#' @importFrom BiocParallel bplapply
#' @importFrom dplyr arrange bind_rows everything group_by select
#' @importFrom rlang !! !!! sym sym
#'
#' @inheritParams annotationFile
#'
#' @return [tibble].
#' @export
#'
#' @examples
#' peptide2gene() %>% glimpse()
peptide2gene <- function(version = NULL, dir = ".") {
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
        pattern = "wormpep_package"
    )
    untar(
        file,
        exdir = dir,
        files = "wormpep.table*"
    )
    wormpepTable <- list.files(
        path = dir,
        pattern = "wormpep.table",
        full.names = TRUE
    )
    lines <- read_lines(wormpepTable)
    dflist <- bplapply(lines, function(line) {
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
