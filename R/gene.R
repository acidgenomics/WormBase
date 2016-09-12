#' Gene annotations.
#' @import utils
#' @param id Identifier.
#' @param format Identifier type (geneID, orf, publicName).
#' @param select Columns to select (report, simple).
#' @return tibble.
#' @examples
#' gene(id = "WBGene00004804", format = "geneId")
#' gene(id = "T19E7.2", format = "orf")
#' gene(id = "skn-1", format = "publicName")
#' @export
gene <- function(id = NULL, format = "geneId", select = "simple") {
    if (format == "orf") {
        id <- gsub("[a-z]{1}$", "", id) # strip isoforms
    }
    # Subset if `id` declared
    if (!is.null(id)) {
        if (format == "geneId") {
            data <- dplyr::filter_(geneData, ~geneId %in% id)
        }
        if (format == "orf") {
            data <- dplyr::filter_(geneData, ~orf %in% id)
        }
        if (format == "publicName") {
            data <- dplyr::filter_(geneData, ~publicName %in% id)
        }
    } else {
        data <- geneData
    }

    if (!is.null(select)) {
        if (select == "simple") {
            data <- dplyr::select_(data, .dots = c("geneId",
                                                   "orf",
                                                   "publicName"))
        } else if (select == "report") {
            data <- dplyr::select_(data, .dots = c("geneId",
                                                   "orf",
                                                   "publicName",
                                                   "geneOtherIds",
                                                   "geneClassDescription",
                                                   "conciseDescription",
                                                   "provisionalDescription",
                                                   "automatedDescription",
                                                   "hsapiensBlastpGeneName",
                                                   "hsapiensBlastpDescription",
                                                   "geneOntologyName",
                                                   "interproDescription",
                                                   "pantherFamilyName",
                                                   "pantherSubfamilyName",
                                                   "pantherGeneOntologyMolecularFunction",
                                                   "pantherGeneOntologyBiologicalProcess",
                                                   "pantherGeneOntologyCellularComponent",
                                                   "pantherClass"))
        } else {
            data <- dplyr::select_(data, .dots = c(format, select))
        }
    }
    return(data)
}
