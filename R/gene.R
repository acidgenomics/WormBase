#' Gene mapping
#'
#' @importFrom dplyr arrange_ bind_rows left_join
#' @importFrom parallel mclapply
#' @importFrom pbmcapply pbmclapply
#' @importFrom stats na.omit
#' @importFrom tidyr separate_
#'
#' @param query Identifier query
#' @param format Identifier type (\code{gene}, \code{name}, \code{sequence},
#'   \code{class} or \code{keyword})
#' @param select Columns to select. Optionally, you can use \code{simple},
#'   \code{report} or \code{NULL} declarations here.
#' @param sort Columns to use for sorting.
#'
#' @return tibble
#' @export
#'
#' @examples
#' gene("skn-1", format = "name")
#' gene("T19E7.2", format = "sequence")
#' gene("WBGene00004804", format = "gene", select = "report")
#' gene("daf", format = "class")
#' gene("bzip", format = "keyword")
gene <- function(query,
                 format = "gene",
                 select = NULL,
                 sort = NULL) {
    if (missing(query)) {
        stop("An identifier is required.")
    } else if (!is.character(query)) {
        stop("Identifier must be a character vector.")
    }
    annotation <- get("geneAnnotation", envir = asNamespace("worminfo"))
    query <- query %>% stats::na.omit(.) %>% unique %>% sort
    if (length(query) < 100) {
        lapply <- parallel::mclapply
    } else {
        lapply <- pbmcapply::pbmclapply
    }
    data <- lapply(seq_along(query), function(a) {
        identifier <- query[a]
        # Format ====
        if (any(grepl(format, c("gene", "name")))) {
            data <- annotation %>%
                .[.[[format]] %in% identifier, ]
        } else if (format == "sequence") {
            # Strip out isoform if necessary
            gsub <- gsub("^([A-Z0-9]+)\\.([0-9]+)[a-z]$", "\\1.\\2", identifier)
            data <- annotation %>% .[.[[format]] %in% gsub, ]
            if (nrow(data)) {
                data$sequence <- query[a]
            }
        } else if (format == "class") {
            name <- annotation %>%
                .[grepl(paste0("^", identifier, "-"), .[["name"]]), "name"]
            name <- name[[1]]
            data <- annotation %>% .[.$name %in% name, ]
        } else if (format == "keyword") {
            # `apply(..., 1)` processes by row:
            grepl <- apply(annotation, 1, function(b) {
                any(grepl(identifier, b, ignore.case = TRUE))
            })
            gene <- annotation[grepl, "gene"]
            gene <- gene[[1]]
            data <- annotation %>% .[.$gene %in% gene, ]
            if (nrow(data)) {
                data$keyword <- identifier[a]
            }
        } else {
            stop("Invalid format.")
        }
        return(data)
    }) %>% dplyr::bind_rows(.)


    # Select ====
    if (is.null(select)) {
        data <- data[, simpleCol]
    } else {
        if (select[[1]] == "report") {
            data <- data[, reportCol]
            # WormBase REST and UniProt.ws calls:
            data <- data %>%
                dplyr::left_join(geneOntology(.$gene), by = "gene") %>%
                dplyr::left_join(geneExternal(.$gene), by = "gene") %>%
                dplyr::left_join(uniprot(.$gene), by = "gene")
        } else {
            data <- data[, unique(c(format, select))]
        }
    }


    # Sort ====
    # `format` is used for sorting (except `keyword`), unless specified:
    if (format == "class") {
        sort <- "name"
    } else if (is.null(sort) && format != "keyword") {
        sort <- format
    }
    if (!is.null(sort)) {
        if (sort[1] == "name") {
            data$temp <- data$name
            # Split to temporary columns for proper sorting later:
            data <- tidyr::separate_(data, "temp",
                                     into = c("tempPrefix", "tempNum"),
                                     sep = "-")
            data$tempNum <- as.numeric(data$tempNum)
            # Sort by class then number:
            data <- dplyr::arrange_(data, .dots = c("tempPrefix", "tempNum"))
            # Drop the unnecessary temporary columns:
            data$tempPrefix <- NULL
            data$tempNum <- NULL
        } else {
            if (!all(sort %in% names(data))) {
                stop("Sort parameters are invalid.")
            }
            data <- dplyr::arrange_(data, .dots = sort)
        }
    }
    return(data)
}
