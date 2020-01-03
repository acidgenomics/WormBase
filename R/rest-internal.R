#' WormBase REST API query
#' @note Updated 2020-01-03.
#' @seealso
#' - https://wormbase.org/about/userguide/for_developers/API-REST
#' - https://rest.wormbase.org (down?)
#' - https://api.wormbase.org (defunct?)
#' @noRd
.rest <- function(query) {
    x <- GET(
        url = paste("https://wormbase.org", "rest", query, sep = "/"),
        config = content_type_json(),
        user_agent = user_agent(userAgent)
    )
    content(x)
}
