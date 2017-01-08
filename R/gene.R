#' Gene mapping
#'
#' @export
#' @importFrom dplyr arrange_ bind_rows
#' @importFrom parallel mclapply
#' @importFrom stats na.omit
#' @importFrom tidyr separate_
#' @param identifier Identifier
#' @param format Identifier type (\code{gene}, \code{name}, \code{sequence},
#'   \code{class} or \code{keyword})
#' @param select Columns to select. Consult the \code{gene} vignette for
#'   available parameters.
#' @return tibble
#'
#' @examples
#' gene("skn-1", format = "name")
#' gene("T19E7.2", format = "sequence")
#' gene("WBGene00004804", format = "gene", select = "descriptionConcise")
#' gene("daf", format = "class")
#' gene("bzip", format = "keyword")
gene <- function(identifier, format = "gene", select = NULL) {
    if (missing(identifier)) {
        stop("An identifier is required.")
    } else if (!is.character(identifier)) {
        stop("Identifier must be a character vector.")
    }
    identifier <- identifier %>% stats::na.omit(.) %>% unique
    annotation <- get("geneAnnotation", envir = asNamespace("worminfo"))
    return <- parallel::mclapply(seq_along(identifier), function(a) {
        if (any(grepl(format, c("gene", "name")))) {
            return <- annotation %>%
                .[.[[format]] %in% identifier[a], ]
        } else if (format == "sequence") {
            # Strip out isoform if necessary
            gsub <- gsub("^([A-Z0-9]+)\\.([0-9]+)[a-z]$", "\\1.\\2", identifier[a])
            return <- annotation %>% .[.[[format]] %in% gsub, ]
        } else if (format == "class") {
            name <- annotation %>%
                .[grepl(paste0("^", identifier[a], "-"), .[["name"]]), "name"]
            name <- name[[1]]
            return <- annotation %>% .[.$name %in% name, ]
        } else if (format == "keyword") {
            # \code{apply(..., 1)} processes by row:
            grepl <- apply(annotation, 1, function(b) {
                any(grepl(identifier[a], b, ignore.case = TRUE))
            })
            gene <- annotation[grepl, "gene"]
            gene <- gene[[1]]
            return <- annotation %>% .[.$gene %in% gene, ]
        } else {
            stop("Invalid format.")
        }
        if (nrow(return)) {
            return[[format]] <- identifier[a]
        }
        return(return)
    }) %>% dplyr::bind_rows(.)

    # Collapse multiple keyword matches:
    if (format == "keyword") {
        return <- return %>%
            dplyr::group_by_(.dots = "gene") %>%
            collapse
    }

    # Select columns:
    # Always return the WormBase gene identifier.
    if (is.null(select)) {
        return <- return[, unique(c(format, simpleCol))]
    } else {
        return <- return[, unique(c(format, "gene", select))]
    }

    # Put \code{format} column first:
    return <- return %>%
        dplyr::select_(.dots = c(format, setdiff(names(.), format)))

    # Arrange rows:
    # \code{format} is used to arrange, unless specified.
    if (any(grepl(format, c("class", "name")))) {
        return$temp <- return$name
        # Split to temporary columns:
        return <- tidyr::separate_(return, "temp",
                                   into = c("tempPrefix", "tempNum"),
                                   sep = "-")
        return$tempNum <- as.numeric(return$tempNum)
        # Arrange by class then number:
        return <- dplyr::arrange_(return, .dots = c("tempPrefix", "tempNum"))
        # Drop the unnecessary temporary columns:
        return$tempPrefix <- NULL
        return$tempNum <- NULL
    } else {
        return <- dplyr::arrange_(return, .dots = unique(format, "gene"))
    }
    return(return)
}
