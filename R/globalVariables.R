# Dot global needed for \code{pipe} function:
utils::globalVariables(c("."))



#' Simple columns
#'
#' @keywords internal
#' @param simpleCol Simple columns
simpleCol <- c("gene", "sequence", "name")



#' User agent for REST API calls
#'
#' @keywords internal
#' @param ua User agent
ua <- "https://github.com/steinbaugh/worminfo"
