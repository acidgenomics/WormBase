#' Default columns for \code{select}
#'
#' @keywords internal
#' @param defaultCol Default columns
defaultCol <- c("gene", "sequence", "name")



#' dplyr funs
#'
#' @importFrom dplyr funs
#' @keywords internal
funs <- function(...) {
    dplyr::funs(...)
}



#' User agent for REST API queries
#'
#' @export
#' @keywords internal
#' @param userAgent User agent
userAgent <- "https://github.com/steinbaugh/worminfo"
