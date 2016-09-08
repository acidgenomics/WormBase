#' Gene annotations
#' @import utils
#' @param id Identifier
#' @param format Identifier type (geneID, orf, publicName)
#' @param output Output type (report, simple)
#' @return tibble
#' @examples
#' gene()
#' gene(output = "simple")
#' gene(id = c("WBGene00004804", "WBGene00001752"), format = "geneId")
#' gene(id = c("T19E7.2", "K08F4.7"), format = "orf")
#' gene(id = c("skn-1", "gst-4"), format = "publicName")
#' @export
gene <- function(id = NULL, format = "geneId", output = "report") {
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
    # Subset columns
    if (output == "report") {
        data <- data[, colNamesReport]
    }
    if (output == "simple") {
        data <- data[, colNamesSimple]
    }
    return(data)
}
