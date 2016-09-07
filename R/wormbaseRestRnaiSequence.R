#' WormBase RESTful RNAi sequence query
#' @import dplyr
#' @import magrittr
#' @param wbrnai WormBase RNAi identifier vector.
#' @return tibble
#' @examples
#' wormbaseRestRnaiSequence("WBRNAi00003982")
#' @export
wormbaseRestRnaiSequence <- function(wbrnai) {
    wbrnai <- sort(wbrnai) %>% unique %>% stats::na.omit(.)
    list <- lapply(seq_along(wbrnai), function(a) {
        data <- wormbaseRest(wbrnai[a], class = "rnai", instance = "sequence") %>%
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
        list(wbrnai = wbrnai[a],
             oligo = oligo,
             length = length,
             sequence = sequence)
    })
    dplyr::bind_rows(list)
}
