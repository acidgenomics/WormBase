#' Convert historical RNAi identifier to WBRNAi with WormBase RESTful API
#'
#' @import magrittr
#'
#' @param vec \code{vector} of WormBase historical RNAi clones
#'
#' @return \code{data.frame}
#' @export
#'
#' @examples
#' historical2wbrnai("JA:K10E9.1")
historical2wbrnai <- function(vec) {
    vec <- sort(unique(vec))
    #! parallel::mclapply
    lapply(vec, function(historical) {
        request <- httr::GET(paste0("http://www.wormbase.org/search/rnai/", historical))
        status <- httr::status_code(request)
        if (status == 200) {
            wbrnai <- tryCatch(request$headers$location) %>%
                stringr::str_extract("WBRNAi[0-9]{8}")
        } else {
            wbrnai <- NA
        }
        c(historical, wbrnai)
    })
}
