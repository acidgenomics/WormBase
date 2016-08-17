#' Feeding RNAi Library clone matching
#'
#' @param cloneId Clone identifier
#' @param lib Feeding library (orfeome, ahringer)
#' @param type Output type (simple, report)
#'
#' @return data.frame with metadata
#' @export
rnai <- function(cloneId = NULL,
                 lib = "orfeome",
                 type = "simple") {
  if (lib == "ahringer") {
    #! ADD GSUB FOR AHRINGER
    df <- ahringerInfo
  } else {
    #! ADD GSUB FOR AHRINGER OR ORFEOME
    df <- orfeomeInfo
  }
  rownames(df) <- df$cloneId

  # Subset rows
  rowNames <- cloneId
  if (!is.null(rowNames)) {
    df <- df[rowNames, ]
  }

  df <- geneBind(df, id = "orf", type = type)

  # Subset columns
  if (type == "report") {
    colNamesReport <- c("cloneId", colNamesReport)
    df <- df[, colNamesReport]
  } else {
    colNamesSimple <- c("cloneId", colNamesSimple)
    df <- df[, colNamesSimple]
  }

  return(df)
}
