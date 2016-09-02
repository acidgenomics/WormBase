#' Gene annotations
#'
#' @param id Identifier
#' @param format Identifier type (geneID, orf, publicName)
#' @param output Output type (report, simple)
#'
#' @return \code{tibble}
#' @examples
#' gene()
#' gene(output = "simple")
#' gene(id = c("WBGene00004804", "WBGene00001752"), format = "geneId")
#' gene(id = c("T19E7.2", "K08F4.7"), format = "orf")
#' gene(id = c("skn-1", "gst-4"), format = "publicName")
#' @export
gene <- function(id = NULL, format = "geneId", output = "report") {
    tbl <- geneData

    # Strip ORF isoforms
    if (format == "orf") {
        id <- gsub("[a-z]{1}$", "", id)
    }

    # Subset if `id` declared
    if (!is.null(id)) {
        if (format == "geneId") {
            tbl <- subset(tbl, tbl$geneId %in% id)
        }
        if (format == "orf") {
            tbl <- subset(tbl, tbl$orf %in% id)
        }
        if (format == "publicName") {
            tbl <- subset(tbl, tbl$publicName %in% id)
        }
    }

    # Subset columns
    if (output == "report") {
        tbl <- tbl[, colNamesReport]
    }
    if (output == "simple") {
        tbl <- tbl[, colNamesSimple]
    }

    return(tbl)
}
