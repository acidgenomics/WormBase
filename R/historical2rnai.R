#' Convert historical RNAi identifier to WBRNAi with WormBase RESTful API.
#' @import httr
#' @import dplyr
#' @import stringr
#' @param historical WormBase historical RNAi experiment vector.
#' @return tibble.
#' @examples
#' historical2rnai("JA:K10E9.1")
#' @export
historical2rnai <- function(historical) {
    historical <- sort(unique(historical)) %>% unique %>% stats::na.omit(.)
    list <- lapply(seq_along(historical), function(a) {
        request <- GET(paste0("http://www.wormbase.org/search/rnai/", historical[a]))
        # Server is now returning 400, need to set error method here?
        rnai <- tryCatch(request$headers$location) %>%
            str_extract("WBRNAi[0-9]{8}")
        if (!length(rnai)) {
            rnai <- NA
        }
        list(historical = historical[a],
             rnai = rnai)
    })
    bind_rows(list)
}
