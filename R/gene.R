#' Gene annotations
#'
#' @param rowNames Identifier vector
#' @param id Identifier type (geneID, orf, publicName)
#' @param output Output type (report, simple)
#'
#' @return metadata data.frame
#' @export
gene <- function(rowNames = NULL, id = "geneId", output = "report") {
  df <- geneInfo
  rownames(df) <- df$geneId

  # Subset columns
  if (output == "simple") {
    df <- df[, colNamesSimple]
  } else {
    df <- df[, colNamesReport]
  }

  # orf matching
  if (id == "orf") {
    if (!is.null(rowNames)) {
      # Strip isoforms from ORF
      rowNames <- gsub("[a-z]{1}$", "", rowNames)
    }
    df <- subset(df, !is.na(df$orf))
    df <- subset(df, !duplicated(df$orf))
    rownames(df) <- df$orf
  }

  # publicName matching
  if (id == "publicName") {
    df <- subset(df, !is.na(df$publicName))
    df <- subset(df, !duplicated(df$publicName))
    rownames(df) <- df$publicName
  }

  # Subset rows
  if (!is.null(rowNames)) {
    df <- df[rowNames, ]
  }

  return(df)
}
