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
    vapply(identifier, FUN = function(x) {
        x %>%
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
    },
    FUN.VALUE = character(1))
}
