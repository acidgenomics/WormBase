#' Gene mapping
#'
#' @import dplyr
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
#' gene("skn-1", format = "name")
#' gene("T19E7.2", format = "sequence")
#' gene("WBGene00004804", format = "gene", select = "report")
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
    annotation <- get("geneAnnotation", envir = asNamespace("worminfo"))
    # Format ====
    if (any(grepl(format, c("gene", "name")))) {
        data <- annotation %>%
            .[.[[format]] %in% identifier, ]
    } else if (format == "sequence") {
        # Strip out isoform information
        identifierClean <- gsub("^([A-Z0-9]+)\\.([0-9]+)[a-z]$",
                                "\\1.\\2",
                                identifier)
        data <- annotation %>%
            .[.[[format]] %in% identifierClean, ]
    } else if (format == "class") {
        sort <- "name"
        list <- lapply(seq_along(identifier), function(a) {
            name <- annotation %>%
                .[grepl(paste0("^", identifier[a], "-"), .[["name"]]), "name"]
            name <- name[[1]]
            data <- annotation %>% .[.[["name"]] %in% name, ]
            return(data)
        })
        data <- dplyr::bind_rows(list)
    } else if (format == "keyword") {
        keywordCol <- c("class",
                        "blastpHsapiensDescription",
                        "ensemblGeneOntologyName",
                        "geneOntologyBiologicalProcess",
                        "geneOntologyCellularComponent",
                        "geneOntologyMolecularFunction",
                        "interproName",
                        "orthologHsapiens",
                        "pantherClass",
                        "pantherFamilyName",
                        "pantherGeneOntologyBiologicalProcess",
                        "pantherGeneOntologyCellularComponent",
                        "pantherGeneOntologyMolecularFunction",
                        "pantherPathway")
        # Subset columns for keyword searching:
        keywordData <- annotation[, keywordCol]
        list <- lapply(seq_along(identifier), function(a) {
            # `apply(..., 1)` processes by row:
            grepl <- apply(keywordData, 1, function(b) {
                any(grepl(identifier[a], b, ignore.case = TRUE))
            })
            gene <- annotation[grepl, "gene"]
            gene <- gene[[1]]
            data <- annotation %>% .[.[["gene"]] %in% gene, ]
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
                            "name")
            } else if (select == "identifiers") {
                select <- c("aceview",
                            "blastpHsapiensGene",
                            "gene",
                            "name",
                            "ncbi",
                            "otherIdentifier",
                            "refseqMrna",
                            "refseqProtein",
                            "sequence",
                            "treefam",
                            "uniprot")
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
                            # "ensemblGeneOntologyName",
                            "geneOntologyBiologicalProcess",
                            "geneOntologyCellularComponent",
                            "geneOntologyMolecularFunction",
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
    # `format` is used for sorting (except `keyword`), unless specified:
    if (is.null(sort) && format != "keyword") {
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
