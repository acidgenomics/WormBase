#' WormBase RESTful RNAi reagent query
#'
#' @import dplyr
#'
#' @param rnai RNAi
#'
#' @return JSON content tibble
#' @export
#'
#' @examples
#' rnaiReagent("WBRNAi00000001")
rnaiReagent <- function(rnai) {
    if (length(identifier) >= restLimit) {
        stop(paste0("A maximum of ", restLimit, " identifiers is allowed."))
    }
    rnai <- rnai %>% unique %>% sort
    list <- lapply(seq_along(rnai), function(a) {
        rest <- paste0("field/rnai/", rnai[a], "/reagent") %>% rest %>%
            .$reagent %>% .$data %>% .[[1]]
        if (length(rest)) {
            list(rnai = rnai[a],
                 oligo = rest$reagent$id,
                 mrc = rest$mrc_id)
        }
    })
    dplyr::bind_rows(lapply(list, function(a) {
        tibble::as_tibble(Filter(Negate(is.null), a))
    }))
}
