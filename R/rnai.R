#' Feeding RNAi Library clone matching
#'
#' @param id Clone identifier
#' @param library Feeding library (ahringer, orfeome)
#' @param format Output type (report, simple)
#'
#' @return data.frame with metadata
#' @examples
#' rnai(library = "ahringer")
#' rnai(id = "III-86@B01", library = "ahringer")
#' rnai(library = "orfeome")
#' rnai(id = "11010@G06", library = "orfeome")
#' @export
rnai <- function(id = NULL, library = "orfeome", format = "report") {
  if (library == "ahringer") {
    id <- gsub("^ahringer", "", id)
    df <- rnaiData$ahringer
  }
  if (library == "orfeome") {
    id <- gsub("^orfeome", "", id)
    df <- rnaiData$orfeome
  }

  if (!is.null(id)) {
    df <- subset(df, df$cloneId %in% id)
  }

  df <- merge(df, gene(df$orf, format = "orf"), by = "orf", all = TRUE)

  if (format == "report") {
    col <- c("cloneId", colNamesReport)
  }
  if (format == "simple") {
    col <- c("cloneId", colNamesSimple)
  }
  df <- df[, col]
  return(df)
}
