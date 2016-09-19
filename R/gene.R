#' Gene annotations.
#'
#' @import dplyr
#'
#' @param id Gene identifier.
#' @param format Identifier type (gene, name, sequence).
#' @param select Columns to select (report, simple).
#'
#' @return tibble.
#'
#' @export
#'
#' @examples
#' gene(id = "WBGene00004804", format = "gene")
#' gene(id = "skn-1", format = "name")
#' gene(id = "T19E7.2", format = "sequence")
gene <- function(id = NULL, format = "gene", select = "simple") {
    # Subset if \code{id} declared
    if (!is.null(id)) {
        id <- sort(id) %>% unique %>% stats::na.omit(.)
        if (format == "gene") {
            data <- filter(worminfo::geneData, gene %in% id)
        }
        if (format == "sequence") {
            data <- filter(worminfo::geneData, sequence %in% id)
        }
        if (format == "name") {
            data <- filter(worminfo::geneData, name %in% id)
        }
    } else {
        data <- worminfo::geneData
    }
    if (!is.null(select)) {
        if (select == "simple") {
            data <- select_(data, .dots = c("gene",
                                            "sequence",
                                            "name"))
        } else if (select == "report") {
            data <- select_(data, .dots = c("gene",
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
        } else {
            data <- select_(data, .dots = c(format, select))
        }
    }
    return(data)
}
