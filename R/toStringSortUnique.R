#' toString call that outputs sorted uniques
#'
#' @keywords general
#' @param vector \code{vector}
#' @return Sorted unique \code{string}
toStringSortUnique <- function(vector) {
    vector %>%
        unique %>%
        sort %>%
        toString %>%
        gsub("NA,\\s|,\\sNA", "", .)
}
