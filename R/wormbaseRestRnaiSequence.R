#' WormBase RESTful RNAi sequence query
#'
#' @import dplyr
#' @import magrittr
#'
#' @return \code{tibble}
#'
#' @examples
#' wormbaseRestRnaiSequence("WBRNAi00003982")
wormbaseRestRnaiSequence <- function(query) {
    query <- sort(query) %>% unique %>% na.omit
    list <- lapply(seq_along(query), function(a) {
        wbrnai <- query[a]
        data <- wormbaseRest(wbrnai, class = "rnai", instance = "sequence") %>%
            .[["sequence"]] %>% .[["data"]] %>% .[[1]]
        if (length(data)) {
            oligo <- data$header
            length <- data$length
            sequence <- data$sequence
        } else {
            oligo <- NA
            length <- NA
            sequence <- NA
        }
        c(wbrnai, oligo, length, sequence)
    })
    tibble::as_tibble(do.call(rbind, list)) %>%
        set_names(c("wbrnai", "oligo", "length", "sequence"))
}
