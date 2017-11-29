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



#' Pretty RNAi Clones
#'
#' We strip the formatting variations down to the bare minimum in the annotation
#' data. This allows for more flexible matching, such as clones that don't
#' contain a padded well number. At the return step, we reformat the clones back
#' to a standardized output, separated by dashes.
#'
#' @keywords internal
#'
#' @inherit minimalClone
#'
#' @export
prettyClone <- function(identifier) {
    identifier %>%
        strsplit(split = ", ") %>%
        .[[1L]] %>%
        # Pad well numbers
        gsub(x = .,
             pattern = "(\\D)(\\d)$",
             replacement = "\\10\\2") %>%
        # Well separator
        gsub(x = .,
             pattern = "(\\d+)(\\D\\d{2})$",
             replacement = "\\1-\\2") %>%
        # Plate separator
        gsub(x = .,
             pattern = "^([a-z]+|[IVX]+)(\\d+)-",
             replacement = "\\1-\\2-") %>%
        toString()
}
