#' WormBase REST API query
#' @note Updated 2019-07-24.
#' @noRd
.rest <- function(query) {
    x <- GET(
        url = paste("http://api.wormbase.org", "rest", query, sep = "/"),
        config = content_type_json(),
        user_agent = user_agent(userAgent)
    )
    content(x)
}
