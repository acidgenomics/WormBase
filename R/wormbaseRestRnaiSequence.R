#' WormBase RESTful RNAi sequence query.
#'
#' @import dplyr
#' @import seqcloudr
#'
#' @param rnai WormBase RNAi identifier.
#'
#' @return tibble.
#' @export
#'
#' @examples
#' wormbaseRestRnaiSequence("WBRNAi00003982")
wormbaseRestRnaiSequence <- function(rnai) {
    rnai <- seqcloudr::toStringUnique(rnai)
    list <- lapply(seq_along(rnai), function(a) {
        data <- worminfo::wormbaseRest(rnai[a], class = "rnai", instance = "sequence") %>%
            .[["sequence"]] %>%
            .[["data"]] %>%
            .[[1]]
        if (length(data)) {
            oligo <- data$header
            length <- data$length
            #! sequence <- data$sequence
        } else {
            oligo <- NA
            length <- NA
            # sequence <- NA
        }
        list(rnai = rnai[a],
             oligo = oligo,
             length = length)
    })
    dplyr::bind_rows(list)
}
