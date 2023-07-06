#' WormBase REST API query
#'
#' @noRd
#' @note Updated 2023-07-06.
#'
#' @seealso
#' - https://wormbase.org/about/userguide/for_developers/API-REST
.rest <- function(query) {
    url <- paste("https://wormbase.org", "rest", query, sep = "/")
    req <- request(url)
    resp <- req_perform(req)
    json <- resp_body_json(resp)
    json
}
