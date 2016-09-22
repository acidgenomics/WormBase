#' Gene annotations
#'
#' @import dplyr
#' @import seqcloudr
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
#' gene("WBGene00004804")
#' gene("WBGene00004804", select = "ncbi")
#' gene("WBGene00004804", select = "all")
#' gene("skn-1", format = "name")
#' gene("T19E7.2", format = "sequence")
gene <- function(identifier, format = "gene", select = NULL) {
    if (!missing(identifier)) {
        identifier <- seqcloudr::sortUnique(identifier)
        if (format == "gene") {
            data <- dplyr::filter(geneData, gene %in% identifier)
        } else if (format == "sequence") {
            data <- dplyr::filter(geneData, sequence %in% identifier)
        } else if (format == "name") {
            data <- dplyr::filter(geneData, name %in% identifier)
        } else {
            stop("Invalid format.")
        }
        if (is.null(select)) {
            data <- dplyr::select_(data, .dots = c("gene",
                                                   "sequence",
                                                   "name",
                                                   "class"))
        } else if (select == "report") {
            data <- dplyr::select_(data, .dots = c("gene",
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
                                                   "pantherClass"))
        } else if (select == "all") {
            data <- data
        } else {
            data <- dplyr::select_(data, .dots = c(format, select))
        }
    } else {
        stop("An identifier is required.")
    }
    return(data)
}
