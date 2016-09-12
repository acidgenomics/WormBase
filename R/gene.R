#' Gene annotations
#' @import utils
#' @param id Identifier
#' @param format Identifier type (geneID, orf, publicName)
#' @param select Columns to select (report, simple)
#' @return tibble
#' @examples
#' gene()
#' gene(output = "simple")
#' gene(id = c("WBGene00004804", "WBGene00001752"), format = "geneId")
#' gene(id = c("T19E7.2", "K08F4.7"), format = "orf")
#' gene(id = c("skn-1", "gst-4"), format = "publicName")
#' @export
gene <- function(id = NULL,
                 format = "geneId",
                 select = NULL) {
    if (format == "orf") {
        id <- gsub("[a-z]{1}$", "", id) # strip isoforms
    }
    # Subset if `id` declared
    if (!is.null(id)) {
        if (format == "geneId") {
            data <- dplyr::filter(geneData, geneId %in% id)
        }
        if (format == "orf") {
            data <- dplyr::filter(geneData, orf %in% id)
        }
        if (format == "publicName") {
            data <- dplyr::filter(geneData, publicName %in% id)
        }
    } else {
        data <- geneData
    }

    if (!is.null(select)) {
        if (select == "simple") {
            data <- dplyr::select(data,
                                  geneId,
                                  orf,
                                  publicName)
        } else if (select == "report") {
            data <- dplyr::select(data,
                                  geneId,
                                  orf,
                                  publicName,
                                  geneOtherIds,
                                  geneClassDescription,
                                  conciseDescription,
                                  provisionalDescription,
                                  automatedDescription,
                                  hsapiensBlastpGeneName,
                                  hsapiensBlastpDescription,
                                  geneOntologyName,
                                  interproDescription,
                                  pantherFamilyName,
                                  pantherSubfamilyName,
                                  pantherGeneOntologyMolecularFunction,
                                  pantherGeneOntologyBiologicalProcess,
                                  pantherGeneOntologyCellularComponent,
                                  pantherClass)
        } else {
            data <- data[, c(format, select)]
        }
    }
    return(data)
}
