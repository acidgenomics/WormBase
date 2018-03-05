#' @importFrom httr content content_type_json GET user_agent
.rest <- function(query) {
    x <- GET(
        url = paste("http://api.wormbase.org", "rest", query, sep = "/"),
        config = content_type_json(),
        user_agent = user_agent(userAgent)
    )
    content(x)
}
