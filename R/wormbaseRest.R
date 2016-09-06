# RNAi clone information
#' WormBase RESTful API query
#'
#' @description
#' \url{http://www.wormbase.org/about/userguide/for_developers/API-REST}
#'
#' @return
wormbaseRest <- function(query, class, instance) {
    httr::GET(paste0("http://api.wormbase.org/rest/field/", class, "/", query, "/", instance),
              config = httr::content_type_json()) %>%
        httr::content(.)
}
