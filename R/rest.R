#' WormBase REST API query
#'
#' @import httr
#'
#' @param url URL query to WormBase RESTful API
#'
#' @return JSON content
#' @export
#'
#' @examples
#' rest("field/gene/WBGene00000001/gene_class")
rest <- function(url) {
    httr::GET(paste0("http://api.wormbase.org/rest/", url),
              config = httr::content_type_json(),
              user_agent = httr::user_agent(ua)) %>%
        httr::content(.)
}
