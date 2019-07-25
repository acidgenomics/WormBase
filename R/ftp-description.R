#' Gene functional descriptions
#'
#' @note As of WS269 release, some non-N2 gene IDs are included in the flat
#'   files available on the WormBase FTP server. These annotations are removed
#'   from the return here, using grep matching to return only `WBGene` entries.
#'
#' @inheritParams params
#'
#' @return `tbl_df`.
#' @export
#'
#' @examples
#' ## Currently failing for WS270, WS271.
#' x <- description(version = "WS269")
#' glimpse(x)

## Updated 2019-07-24.
description <- function(
    version = NULL,
    progress = FALSE
) {
    pblapply <- .pblapply(progress = progress)
    file <- .annotationFile(
        pattern = "functional_descriptions",
        version = version
    )

    ## Process file by reading lines in directly.
    ## The first 3 lines contain comments.
    message("Parsing lines in file...")
    lines <- file %>%
        unname() %>%
        read_lines(skip = 3L, progress = FALSE) %>%
        ## Genes are separated by a line containing `=`.
        gsub(pattern = "^=$", replacement = "\\|\\|", x = .) %>%
        ## Add a tab delimiter before our keys of interest:
        ## - Concise description
        ## - Provisional description
        ## - Detailed description
        ## - Automated description
        ## - Gene class description
        gsub(
            pattern = paste0(
                "(Concise|Provisional|Detailed|Automated|Gene class)",
                " description\\:"
            ),
            replacement = "\t\\1 description:",
            x = .
        ) %>%
        ## Now collapse to a single line and split by the gene separator (`||`).
        paste(collapse = " ") %>%
        strsplit("\\|\\|") %>%
        unlist() %>%
        ## Clean up spaces and tabs.
        gsub("  ", " ", .) %>%
        gsub("^ ", "", .) %>%
        gsub(" $", "", .) %>%
        gsub(" \t", "\t", .) %>%
        gsub("\t ", "\t", .) %>%
        ## Now split by the tab delimiters.
        strsplit("\t")

    ## Before we process the list, remove non-N2 annotations.
    ## These were added in WS269.
    ## For example, drop these: "PRJEB28388_chrIII_pilon.g6684".
    keep <- bapply(
        X = lines,
        FUN = function(x) {
            grepl(pattern = genePattern, x = x[[1L]])
        }
    )
    if (!any(keep)) {
        .invalidFTPFile(file)
    }
    lines <- lines[keep]

    ## Parallelize the processing steps here to speed up the return.
    message("Processing functional descriptions...")
    dflist <- pblapply(lines, function(x) {
        ## This step checks for columns such as "Concise description:".
        keyPattern <- "^([A-Za-z[:space:]]+)\\:"
        names <- str_match(x, pattern = keyPattern)[, 2L]
        ## The first 3 columns won't match the pattern, so assign manually.
        names[1L:3L] <- c("geneID", "geneName", "sequence")
        names <- camelCase(names)
        x %>%
            ## Remove the key prefix (e.g. "Concise description:").
            gsub(
                pattern = paste0(keyPattern, " "),
                replacement = "",
                x = .
            ) %>%
            set_names(names) %>%
            t() %>%
            as_tibble() %>%
            ## Ensure the user uses the values from `geneIDs()` return instead.
            .[, setdiff(colnames(.), c("geneName", "sequence"))]
    })

    dflist %>%
        bind_rows() %>%
        camelCase() %>%
        sanitizeNA() %>%
        removeNA() %>%
        arrange(!!sym("geneID"))
}

formals(description)[["version"]] <- versionArg
