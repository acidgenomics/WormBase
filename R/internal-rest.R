#' @importFrom httr content content_type_json GET user_agent
.rest <- function(url) {
    file.path("http://api.wormbase.org", "rest", url) %>%
        GET(config = content_type_json(),
            user_agent = user_agent(userAgent)) %>%
        content()
}
