#' WormBase RESTful RNAi sequence query
#'
#' @import dplyr
#'
#' @param rnai RNAi
#'
#' @return JSON content tibble
#' @export
#'
#' @examples
#' rnaiSequence("WBRNAi00000001")
rnaiSequence <- function(rnai) {
    rnai <- rnai %>% unique %>% sort
    list <- lapply(seq_along(rnai), function(a) {
        rest <- paste0("field/rnai/", rnai[a], "/sequence") %>% rest %>%
            .$sequence %>% .$data %>% .[[1]]
        if (length(rest)) {
            list(rnai = rnai[a],
                 oligo = rest$header,
                 length = rest$length,
                 sequence = rest$sequence)
        }
    })
    dplyr::bind_rows(lapply(list, function(a) {
        tibble::as_tibble(Filter(Negate(is.null), a))
    }))
}
