#' Feeding RNAi Library clone matching
#'
#' @param id Clone identifier
#' @param well
#' @param format Output type (report, simple)
#'
#' @return data.frame with metadata
#' @examples
#' rnai(library = "ahringer")
#' rnai(id = "III-86@B01", library = "ahringer")
#' rnai(library = "orfeome")
#' rnai(id = "11010@G06", library = "orfeome")
#' @export
ahringer <- function(id = NULL, well = 384, format = "report") {
  df <- ahringerData

  if (well == 96) {
    cloneId <- df$ahringerId96
  }
  if (well == 384) {
    cloneId <- df$ahringerId384
  }

  df <- cbind(cloneId, df)

  if (!is.null(id)) {
    df <- subset(df, df$cloneId %in% id)
  }

  df$orf <- df$genePair
  df <- merge(df, gene(df$orf, format = "orf"), by = "orf", all = TRUE)
  df$orf <- NULL

  if (format == "report") {
    col <- c("cloneId", colNamesReport)
  }
  if (format == "simple") {
    col <- c("cloneId", colNamesSimple)
  }
  df <- df[, col]
  return(df)
}
