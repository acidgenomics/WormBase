#' Gene annotations
#'
#' @param id Identifier
#' @param format Identifier type (geneID, orf, publicName)
#' @param output Output type (report, simple)
#'
#' @return metadata data.frame
#' @examples
#' gene()
#' gene(output = "simple")
#' gene(id = c("WBGene00004804", "WBGene00001752"), format = "geneId")
#' gene(id = c("T19E7.2", "K08F4.7"), format = "orf")
#' gene(id = c("skn-1", "gst-4"), format = "publicName")
#' @export
gene <- function(id = NULL, format = "geneId", output = "report") {
  df <- geneData

  # Strip ORF isoforms
  if (format == "orf") {
    id <- gsub("[a-z]{1}$", "", id)
  }

  # Subset if `id` declared
  if (!is.null(id)) {
    if (format == "geneId") {
      df <- subset(df, df$geneId %in% id)
    }
    if (format == "orf") {
      df <- subset(df, df$orf %in% id)
    }
    if (format == "publicName") {
      df <- subset(df, df$publicName %in% id)
    }
  }

  # Subset columns
  if (output == "report") {
    df <- df[, colNamesReport]
  }
  if (output == "simple") {
    df <- df[, colNamesSimple]
  }

  return(df)
}
