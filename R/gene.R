#' Gene mapping
#'
#' @author Michael Steinbaugh
#'
#' @param identifier Identifier
#' @param format Identifier type (\code{gene}, \code{name}, \code{sequence},
#'   \code{class} or \code{keyword})
#' @param select Columns to select. Consult the \code{gene} vignette for
#'   available parameters.
#'
#' @return tibble
#' @export
#'
#' @examples
#' gene("skn-1", format = "name")
#' gene("T19E7.2", format = "sequence")
#' gene("WBGene00004804", select = "descriptionConcise")
#' gene("daf", format = "class")
#' gene("bzip", format = "keyword")
gene <- function(
    identifier,
    format = "gene",
    select = NULL) {
    identifier <- uniqueIdentifier(identifier)
    annotation <- get("annotation", envir = asNamespace("worminfo"))$gene
    return <- mclapply(seq_along(identifier), function(a) {
        if (any(grepl(format, c("gene", "name")))) {
            return <- annotation %>%
                .[.[[format]] %in% identifier[a], ]
        } else if (format == "sequence") {
            sequence <- removeIsoform(identifier)
            return <- annotation %>% .[.[[format]] %in% sequence[a], ]
        } else if (format == "class") {
            name <- annotation %>%
                .[grepl(paste0("^", identifier[a], "-"), .[["name"]]), "name"]
            name <- name[[1]]
            return <- annotation %>% .[.$name %in% name, ]
        } else if (format == "keyword") {
            # \code{apply(..., 1)} processes by row
            grepl <- apply(annotation, 1, function(b) {
                any(grepl(identifier[a], b, ignore.case = TRUE))
            })
            gene <- annotation[grepl, "gene"]
            gene <- gene[[1]]
            return <- annotation %>% .[.$gene %in% gene, ]
        } else {
            stop("invalid format")
        }
        if (nrow(return)) {
            return[[format]] <- identifier[a]
        }
        return(return)
    }) %>% bind_rows
    # Select columns
    # Always return the WormBase gene identifier
    if (is.null(select)) {
        return <- return[, unique(c(format, defaultCol))]
    } else {
        return <- return[, unique(c(format, defaultCol, select))]
    }
    # Put \code{format} column first
    return <- return %>%
        select_(.dots = c(format, setdiff(names(.), format)))
    if (nrow(return)) {
        # Summarize multiple keyword matches
        if (format == "keyword") {
            return <- return %>%
                group_by_(.dots = "gene") %>%
                toStringSummarize
        }
        # Arrange rows
        # \code{format} is used to arrange, unless specified
        if (any(grepl(format, c("class", "name")))) {
            arrange <- str_match(return$name, "^(.+)([0-9\\.]+)$") %>%
                as_tibble
            arrange$V3 <- as.numeric(arrange$V3)
            return <- left_join(return, arrange, by = c("name" = "V1"))
            # Arrange by class then number:
            return <- arrange_(return, .dots = c("V2", "V3"))
            # Drop the unnecessary temporary columns:
            return$V2 <- NULL
            return$V3 <- NULL
        } else {
            return <- arrange_(return, .dots = unique(format, defaultCol))
        }
    }
    return(return)
}
