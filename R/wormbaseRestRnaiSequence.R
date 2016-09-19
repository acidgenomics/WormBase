#' WormBase RESTful RNAi sequence query.
#' @import dplyr
#' @param rnai WormBase RNAi identifier.
#' @return tibble.
#' @examples
#' wormbaseRestRnaiSequence("WBRNAi00003982")
#' @export
wormbaseRestRnaiSequence <- function(rnai) {
    rnai <- sort(rnai) %>% unique %>% stats::na.omit(.)
    list <- lapply(seq_along(rnai), function(a) {
        data <- wormbaseRest(rnai[a], class = "rnai", instance = "sequence") %>%
            .[["sequence"]] %>% .[["data"]] %>% .[[1]]
        if (length(data)) {
            oligo <- data$header
            length <- data$length
            # sequence <- data$sequence
        } else {
            oligo <- NA
            length <- NA
            # sequence <- NA
        }
        list(rnai = rnai[a],
             oligo = oligo,
             length = length)
    })
    bind_rows(list)
}
