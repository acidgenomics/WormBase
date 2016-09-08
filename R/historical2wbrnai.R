#' Convert historical RNAi identifier to WBRNAi with WormBase RESTful API
#' @import magrittr
#' @param historical WormBase historical RNAi experiment vector.
#' @return tibble
#' @examples
#' historical2wbrnai("JA:K10E9.1")
#' @export
historical2wbrnai <- function(historical) {
    historical <- sort(unique(historical)) %>% unique %>% stats::na.omit(.)
    list <- lapply(seq_along(historical), function(a) {
        request <- httr::GET(paste0("http://www.wormbase.org/search/rnai/", historical[a]))
        # Server is now returning 400, need to set error method here
        # warning, error
        wbrnai <- tryCatch(request$headers$location) %>%
            stringr::str_extract(., "WBRNAi[0-9]{8}")
        list(wormbaseHistorical = historical, wbrnai = wbrnai)
    })
    dplyr::bind_rows(list)
}
