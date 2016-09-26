#' Gene annotations
#'
#' @param identifier Gene identifier
#' @param format Identifier type (\code{gene}, \code{name} or \code{sequence})
#' @param select Columns to select (e.g. \code{ncbi}).
#'   Optionally, you can use \code{all} or \code{report} declarations here.
#'
#' @return tibble
#' @export
#'
#' @examples
#' gene("WBGene00004804", select = "ncbi")
#' gene("skn-1", format = "name")
#' gene("T19E7.2", format = "sequence")
gene <- function(identifier,
                 format = "gene",
                 select = NULL) {
    data <- get("geneData", envir = asNamespace("worminfo"))
    if (!missing(identifier)) {
        if (!is.character(identifier)) {
            stop("Identifier must be a character vector.")
        }
        identifier <- sort(unique(identifier))
        if (any(grepl(format,
                      c("gene",
                        "name",
                        "sequence")))) {
            data <- data[data[[format]] %in% identifier, ]
        } else {
            stop("Invalid format.")
        }
        if (is.null(select)) {
            data <- data[, c("gene",
                             "sequence",
                             "name",
                             "class")]
        } else if (select[1] == "report") {
            data <- data[, c("gene",
                             "sequence",
                             "name",
                             "class",
                             "otherIdentifier",
                             "ncbi",
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
                             "pantherClass")]
        } else if (select[1] == "all") {
            data <- data
        } else {
            data <- data[, c(format, select)]
        }
    } else {
        stop("An identifier is required.")
    }
    return(data)
}
