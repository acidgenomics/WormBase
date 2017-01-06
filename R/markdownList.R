#' Markdown formatted list
#' @export
#' @param vector Character vector
#' @return Markdown list
markdownList <- function(vector) {
    sapply(seq_along(vector), function(a) {
        paste0("- ", vector[a])
    }) %>%
        paste(collapse = "\n") %>%
        cat
}
