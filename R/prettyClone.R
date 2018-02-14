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
#'
#' @examples
#' prettyClone(c("11010G6", "III6C1"))
prettyClone <- function(identifier) {
    vec <- vapply(identifier, FUN = function(x) {
        x %>%
            strsplit(split = ", ") %>%
            .[[1L]] %>%
            # Pad well numbers
            gsub("(\\D)(\\d)$", "\\10\\2", .) %>%
            # Well separator
            gsub("(\\d+)(\\D\\d{2})$", "\\1-\\2", .) %>%
            # Plate separator
            gsub("^([a-z]+|[IVX]+)(\\d+)-", "\\1-\\2-", .) %>%
            toString()
    },
    FUN.VALUE = character(1))
    names(vec) <- NULL
    vec
}
