#' Gene mapping
#'
#' @importFrom dplyr arrange_ bind_rows
#' @importFrom stats na.omit
#' @importFrom tidyr separate_
#'
#' @param identifier Gene identifier
#' @param format Identifier type (\code{gene}, \code{name}, \code{sequence},
#'   \code{class} or \code{keyword})
#' @param select Columns to select (e.g. \code{ncbi}). Optionally, you can use
#'   \code{simple}, \code{report} or \code{NULL} declarations here.
#' @param sort Columns to use for sorting.
#'
#' @return tibble
#' @export
#'
#' @examples
#' gene("WBGene00004804", select = "report")
#' gene("skn-1", format = "name")
#' gene("T19E7.2", format = "sequence")
#' gene("daf", format = "class")
#' gene("bzip", format = "keyword")
gene <- function(identifier,
                 format = "gene",
                 select = "simple",
                 sort = NULL) {
    if (missing(identifier)) {
        stop("An identifier is required.")
    } else if (!is.character(identifier)) {
        stop("Identifier must be a character vector.")
    }
    identifier <- sort(unique(stats::na.omit(identifier)))
    source <- get("geneSource", envir = asNamespace("worminfo"))
    # Format ====
    if (any(grepl(format,
                  c("gene",
                    "name",
                    "sequence")))) {
        data <- source[source[[format]] %in% identifier, ]
    } else if (format == "class") {
        list <- lapply(seq_along(identifier), function(a) {
            name <- source[grepl(paste0("^", identifier[a], "-"),
                                 source[["name"]]), "name"]
            name <- name[[1]]
            data <- source[source[["name"]] %in% name, ]
            return(data)
        })
        data <- dplyr::bind_rows(list)
    } else if (format == "keyword") {
        keywordCol <- c("class",
                        "blastpHsapiensDescription",
                        # "descriptionAutomated",
                        # "descriptionConcise",
                        # "descriptionDetailed",
                        # "descriptionProvisional",
                        "geneOntologyName",
                        "interproName",
                        "pantherClass",
                        "pantherFamilyName",
                        "pantherGeneOntologyBiologicalProcess",
                        "pantherGeneOntologyCellularComponent",
                        "pantherGeneOntologyMolecularFunction",
                        "pantherPathway")
        # Subset columns for keyword searching:
        keywordData <- source[, keywordCol]
        list <- lapply(seq_along(identifier), function(a) {
            # `apply(..., 1)` processes by row:
            grepl <- apply(keywordData, 1, function(b) {
                any(grepl(identifier[a], b, ignore.case = TRUE))
            })
            gene <- source[grepl, "gene"]
            gene <- gene[[1]]
            data <- source[source[["gene"]] %in% gene, ]
            data$keyword <- identifier[a]
            return(data)
        })
        data <- dplyr::bind_rows(list)
    } else {
        stop("Invalid format.")
    }
    # Select ====
    if (!is.null(select)) {
        if (length(select) == 1) {
            if (select == "simple") {
                select <- c("gene",
                            "sequence",
                            "name",
                            "class")
            } else if (select == "identifiers") {
                select <- c("aceview",
                            "blastpHsapiensGene",
                            "blastpHsapiensName",
                            "gene",
                            "hsapiensGene",
                            "name",
                            "ncbi",
                            # "omim",
                            "otherIdentifier",
                            "peptide",
                            "refseqMrna",
                            "refseqProtein",
                            "sequence",
                            "treefam",
                            "uniprot",
                            "wormpep")
            } else if (select == "keyword") {
                select <- c("gene",
                            "sequence",
                            "name",
                            keywordCol)
            } else if (select == "report") {
                select <- c("gene",
                            "sequence",
                            "name",
                            "class",
                            "descriptionConcise",
                            "descriptionProvisional",
                            "descriptionAutomated",
                            "descriptionEnsembl",
                            "blastpHsapiensGene",
                            "blastpHsapiensName",
                            "blastpHsapiensDescription",
                            "geneOntologyName",
                            "interproName",
                            "pantherFamilyName",
                            "pantherSubfamilyName",
                            "pantherGeneOntologyMolecularFunction",
                            "pantherGeneOntologyBiologicalProcess",
                            "pantherGeneOntologyCellularComponent",
                            "pantherClass")
            }
        }
        select <- unique(c(format, select))
        data <- data[, select]
    }
    # Sort ====
    # `format` is used for sorting (except "keyword") unless specified:
    if (is.null(sort) && format != "keyword") {
        sort <- format
    }
    if (!is.null(sort)) {
        if (sort[1] == "name") {
            data$temp <- data$name
            # Split to temporary columns for proper sorting later
            data <- tidyr::separate_(data, "temp", c("tempPrefix", "tempNum"))
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
