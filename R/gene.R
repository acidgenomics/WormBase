#' Gene mapping
#'
#' @import dplyr
#' @import pbmcapply
#' @importFrom parallel mclapply
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
        fxn <- parallel::mclapply
    } else {
        fxn <- pbmcapply::pbmclapply
    }
    list <- fxn(seq_along(query), function(a) {
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
            # Subset columns for keyword searching:
            keywordData <- annotation[, keywordCol]
            # `apply(..., 1)` processes by row:
            grepl <- apply(keywordData, 1, function(b) {
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
    })
    data <- dplyr::bind_rows(list)


    # Select ====
    if (is.null(select)) {
        select <- simpleCol
    } else {
        if (length(select) == 1) {
            if (select == "keyword") {
                select <- c(simpleCol, keywordCol)
            } else if (select == "report") {
                select <- c(simpleCol,
                            "class",

                            # Ortholog:
                            "blastpHsapiensGene",
                            "blastpHsapiensName",
                            "blastpHsapiensDescription",
                            "orthologHsapiens",

                            # Description:
                            "descriptionConcise",
                            "descriptionProvisional",
                            "descriptionAutomated",
                            "ensemblDescription",

                            # WormBase Additional:
                            "rnaiPhenotype",

                            # Gene Ontology:
                            "geneOntologyBiologicalProcess",
                            "geneOntologyCellularComponent",
                            "geneOntologyMolecularFunction",
                            "ensemblGeneOntology",
                            "interpro",
                            "pantherFamilyName",
                            "pantherSubfamilyName",
                            "pantherGeneOntologyMolecularFunction",
                            "pantherGeneOntologyBiologicalProcess",
                            "pantherGeneOntologyCellularComponent",
                            "pantherClass")
            }
        }
    }
    select <- unique(c(format, select))
    data <- data[, select]


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
            # Split to temporary columns for proper sorting later
            data <- tidyr::separate_(data, "temp",
                                     into = c("tempPrefix", "tempNum"),
                                     sep = "-")
            data$tempNum <- as.numeric(data$tempNum)
            # Sort by class then number
            data <- dplyr::arrange_(data, .dots = c("tempPrefix", "tempNum"))
            # Drop the unnecessary temporary columns
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
