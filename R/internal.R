#' Default columns for \code{select}
#' @param defaultCol Default columns
defaultCol <- c("gene", "sequence", "name")



#' @importFrom dplyr funs
funs <- function(...) {
    dplyr::funs(...)
}



#' User agent for REST API queries
#' @param userAgent User agent
userAgent <- "https://github.com/steinbaugh/worminfo"



# Dot global needed for piping:
utils::globalVariables(c("."))
