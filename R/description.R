#' Gene Functional Descriptions
#'
#' @family FTP File Functions
#'
#' @inheritParams general
#'
#' @return `tbl_df`.
#' @export
#'
#' @examples
#' invisible(capture.output(
#'     x <- description()
#' ))
#' glimpse(x)
description <- function(version = NULL, dir = ".") {
    file <- .annotationFile(
        pattern = "functional_descriptions",
        version = version,
        dir = dir
    )

    # The first 3 lines contain comments
    lines <- read_lines(
        file = as.character(file),
        skip = 3L,
        progress = FALSE
    )

    # Genes are separated by a line containing `=`
    lines <- gsub("^=$", "\\|\\|", lines)

    # Add a tab delimiter before our keys of interest:
    # - Concise description
    # - Provisional description
    # - Detailed description
    # - Automated description
    # - Gene class description
    lines <- gsub(
        pattern = paste0(
            "(Concise|Provisional|Detailed|Automated|Gene class)",
            " description\\:"
        ),
        replacement = "\t\\1 description:",
        x = lines
    )

    # Now collapse to a single line and split by the gene separator (`||`)
    lines <- lines %>%
        paste(collapse = " ") %>%
        strsplit("\\|\\|") %>%
        unlist()

    # Clean up spaces and tabs
    lines <- lines %>%
        gsub("  ", " ", .) %>%
        gsub("^ ", "", .) %>%
        gsub(" $", "", .) %>%
        gsub(" \t", "\t", .) %>%
        gsub("\t ", "\t", .)

    # Now split by the tab delimiters
    lines <- strsplit(lines, "\t")

    # Make this call parallel
    dflist <- pblapply(lines, function(x) {
        keyPattern <- "^([A-Za-z[:space:]]+)\\:"
        names <- str_match(x, keyPattern)[, 2L]
        names[1:3] <- c("geneID", "geneName", "sequence")
        names <- make.names(names)
        # Now remove the keys
        x <- gsub(paste0(keyPattern, " "), "", x)
        names(x) <- names
        tbl <- as_tibble(t(x))
        # Ensure the user uses the values from `geneIDs()` instead
        tbl[["geneName"]] <- NULL
        tbl[["sequence"]] <- NULL
        tbl
    })

    dflist %>%
        bind_rows() %>%
        camel() %>%
        fixNA() %>%
        removeNA()
}
