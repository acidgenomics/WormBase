#' Gene annotations.
#' @import dplyr
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
    # Subset if \code{id} declared
    if (!is.null(id)) {
        id <- sort(id) %>% unique %>% stats::na.omit(.)
        if (format == "geneId") {
            data <- filter(geneData, geneId %in% id)
        }
        if (format == "orf") {
            id <- gsub("[a-z]{1}$", "", id) # strip isoforms
            data <- filter(geneData, orf %in% id)
        }
        if (format == "publicName") {
            data <- filter(geneData, publicName %in% id)
        }
    } else {
        data <- geneData
    }

    if (!is.null(select)) {
        if (select == "simple") {
            data <- select_(data, .dots = c("geneId",
                                            "orf",
                                            "publicName"))
        } else if (select == "report") {
            data <- select(data, .dots = c("geneId",
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
            data <- select_(data, .dots = c(format, select))
        }
    }
    return(data)
}
