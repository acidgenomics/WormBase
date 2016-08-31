#' Feeding RNAi Library clone matching
#'
#' @param id Clone identifier
#' @param wells Library plate format (96, 384)
#' @param format Output type (report, simple)
#'
#' @return data.frame with metadata
#' @examples
#' ahringer("III-86@B01")
#' @export
ahringer <- function(id = NULL, wells = 384, format = "report") {
    df <- ahringerData

    if (wells == 96) {
        cloneId <- df$ahringerId96
    }
    if (wells == 384) {
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
