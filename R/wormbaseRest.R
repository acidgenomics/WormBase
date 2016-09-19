#' WormBase RESTful API query.

#' @import httr

#' @param query A WormBase gene identifier (e.g. WBGene00000001).
#' @param class A class (e.g. gene).
#' @param instance An instance (e.g. concise_description).

#' @description
#' \url{http://www.wormbase.org/about/userguide/for_developers/API-REST}

#' @export
wormbaseRest <- function(query, class, instance) {
    GET(paste0("http://api.wormbase.org/rest/field/", class, "/", query, "/", instance),
        config = content_type_json()) %>%
        content(.)
}
