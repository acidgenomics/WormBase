#' Minimal RNAi Clones
#'
#' Strip out unnecessary plate and well separators. Also remove zero padding
#' for well numbers, for fast and consistent clone matching.
#'
#' @keywords internal
#'
#' @param identifier Clone identifier.
#'
#' @return Character vector.
#' @export
minimalClone <- function(identifier) {
    identifier %>%
        # Remove `@` and `-` from clones
        gsub(x = .,
             pattern = "[@-]",
             replacement = "") %>%
        # Strip padded zero from well number
        gsub(x = .,
             pattern = "([A-Z])0([1-9])",
             replacement = "\\1\\2")
}
