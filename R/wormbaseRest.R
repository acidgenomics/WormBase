#' WormBase RESTful API query
#' @param query a WBGene ID (e.g. WBGene00006763)
#' @param class a class (e.g. gene)
#' @param instance an instance (e.g. concise_description)
#' @description
#' \url{http://www.wormbase.org/about/userguide/for_developers/API-REST}
#' @export
wormbaseRest <- function(query, class, instance) {
    httr::GET(paste0("http://api.wormbase.org/rest/field/", class, "/", query, "/", instance),
              config = httr::content_type_json()) %>%
        httr::content(.)
}
