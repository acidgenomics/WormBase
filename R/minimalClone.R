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
#'
#' @examples
#' minimalClone(c("11010-G06", "11010@G06", "III-6-C01"))
minimalClone <- function(identifier) {
    identifier %>%
        # Remove `@` and `-` from clones
        gsub("[@-]", "", .) %>%
        # Strip padded zero from well number
        gsub("([A-Z])0([1-9])", "\\1\\2", .)
}
