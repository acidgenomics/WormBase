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
orfeome <- function(id = NULL, library = "orfeome", format = "report") {
    if (library == "ahringer") {
        if (!is.null(id)) {
            id <- gsub("^ahringer", "", id)
        }
        df <- ahringerData
    }
    if (library == "orfeome") {
        if (!is.null(id)) {
            id <- gsub("^GHR-", "orfeome", id)
        }
        df <- orfeomeData
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

orfeomeData
