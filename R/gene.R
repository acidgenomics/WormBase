#' Gene Mapping
#'
#' @importFrom basejump collapseToString
#' @importFrom dplyr arrange everything group_by left_join select
#' @importFrom parallel mclapply
#' @importFrom rlang !!! syms
#' @importFrom stringr str_match
#' @importFrom tibble as_tibble
#'
#' @param identifier Identifier.
#' @param format Identifier type (`gene`, `name`, `sequence`, `class` or
#'   `keyword`).
#' @param select Columns to select. Consult `vignette("gene")` for the list of
#'   available parameters.
#'
#' @return [data.frame].
#' @export
#'
#' @examples
#' # name
#' gene("skn-1", format = "name")
#'
#' # sequence
#' gene("T19E7.2", format = "sequence")
#'
#' # description
#' gene("WBGene00004804", select = "descriptionConcise")
#'
#' # class
#' gene("daf", format = "class")
#'
#' # keyword
#' gene("bzip", format = "keyword")
gene <- function(
    identifier,
    format = "gene",
    select = NULL) {
    identifier <- .uniqueIdentifier(identifier)
    worminfo <- worminfo::worminfo[["gene"]]
    return <- mclapply(seq_along(identifier), function(a) {
        if (any(grepl(format, c("gene", "name")))) {
            return <- worminfo %>%
                .[.[[format]] %in% identifier[[a]], ]
        } else if (format == "sequence") {
            sequence <- .removeIsoform(identifier)
            return <- worminfo %>%
                .[.[[format]] %in% sequence[[a]], ]
        } else if (format == "class") {
            name <- worminfo %>%
                .[grepl(paste0("^", identifier[[a]], "-"), .[["name"]]), "name"]
            name <- name[[1L]]
            return <- worminfo %>%
                .[.[["name"]] %in% name, ]
        } else if (format == "keyword") {
            # `apply(..., 1)` processes by row
            grepl <- apply(worminfo, 1L, function(b) {
                any(grepl(identifier[a], b, ignore.case = TRUE))
            })
            gene <- worminfo[grepl, "gene"]
            gene <- gene[[1L]]
            return <- worminfo %>%
                .[.[["gene"]] %in% gene, ]
        } else {
            stop("Invalid format")
        }
        if (nrow(return)) {
            return[[format]] <- identifier[a]
        }
        return
    })
    return <- bind_rows(return)
    # Select columns. Always return the WormBase gene identifier.
    if (is.null(select)) {
        return <- return[, unique(c(format, defaultCol))]
    } else {
        return <- return[, unique(c(format, defaultCol, select))]
    }
    return <- select(return, .data[[format]], everything())
    if (nrow(return)) {
        # Summarize multiple keyword matches
        if (format == "keyword") {
            return <- return %>%
                group_by(!!sym("gene")) %>%
                collapseToString()
        }
        # Arrange rows
        # `format` is used to arrange, unless specified
        if (any(grepl(format, c("class", "name")))) {
            arrange <- str_match(return[["name"]], "^(.+)([0-9\\.]+)$") %>%
                as_tibble()
            arrange[["V3"]] <- as.numeric(arrange[["V3"]])
            return <- left_join(return, arrange, by = c("name" = "V1"))
            # Arrange by class then number:
            return <- arrange(return, !!!syms(c("V2", "V3")))
            # Drop the unnecessary temporary columns:
            return[["V2"]] <- NULL
            return[["V3"]] <- NULL
        } else {
            return <- arrange(return, !!!syms(unique(format, defaultCol)))
        }
    }
    as.data.frame(return)
}
