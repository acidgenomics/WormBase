#' @importFrom httr content content_type_json GET user_agent
rest <- function(url) {
    httr::GET(paste0("http://api.wormbase.org/rest/", url),
              config = httr::content_type_json(),
              user_agent = httr::user_agent(userAgent)) %>%
        httr::content(.)
}
