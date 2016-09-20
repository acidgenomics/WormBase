#' Convert historical RNAi identifier to WBRNAi with WormBase RESTful API.
#'
#' @import httr
#' @import dplyr
#' @import stats
#' @import stringr
#'
#' @param historical WormBase historical RNAi experiment vector.
#'
#' @return tibble.
#' @export
#'
#' @examples
#' historical2rnai("JA:K10E9.1")
historical2rnai <- function(historical) {
    historical <- historical %>%
        stats::na.omit(.) %>%
        unique(.) %>%
        sort(.)
    list <- lapply(seq_along(historical), function(a) {
        request <- httr::GET(paste0("http://www.wormbase.org/search/rnai/", historical[a]))
        # Server is now returning 400, need to set error method here?
        rnai <- tryCatch(request$headers$location) %>%
            stringr::str_extract("WBRNAi[0-9]{8}")
        if (!length(rnai)) {
            rnai <- NA
        }
        list(historical = historical[a],
             rnai = rnai)
    })
    dplyr::bind_rows(list)
}
