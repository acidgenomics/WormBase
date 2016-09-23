#' Gene annotations
#'
#' @import dplyr
#' @importFrom utils download.file
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
gene <- function(identifier,
                 format = "gene",
                 select = NULL) {
    # Download gene source data:
    if (!exists("geneData", envir = parent.frame())) {
        assign("geneData", tempfile(), envir = parent.frame())
        utils::download.file(geneDataFile, get("geneData", envir = parent.frame()))
        load(get("geneData", envir = parent.frame()))
    }
    data <- get("geneData", envir = parent.frame())
    if (!missing(identifier)) {
        identifier <- sort(unique(identifier))
        if (format == "gene") {
            data <- dplyr::filter(gene, gene %in% identifier)
        } else if (format == "sequence") {
            data <- dplyr::filter(gene, sequence %in% identifier)
        } else if (format == "name") {
            data <- dplyr::filter(gene, name %in% identifier)
        } else {
            stop("Invalid format.")
        }
        if (is.null(select)) {
            data <- dplyr::select_(data, .dots = c("gene",
                                                   "sequence",
                                                   "name",
                                                   "class"))
        } else if (select[1] == "report") {
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
        } else if (select[1] == "all") {
            data <- data
        } else {
            data <- dplyr::select_(data, .dots = c(format, select))
        }
    } else {
        stop("An identifier is required.")
    }
    return(data)
}
