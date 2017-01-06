#' grep match for toString
#'
#' @keywords internal
#' @param identifier Identifier
#' @return grep \code{string}
grepString <- function(identifier) {
    identifier %>%
        paste0(
            # Unique:
            "^", ., "$",
            "|",
            # Beginning of list:
            "^", ., ",",
            "|",
            # Middle of list:
            "\\s", ., ",",
            "|",
            # End of list:
            "\\s", ., "$")
}
