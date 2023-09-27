#' WormBase REST API query
#'
#' @noRd
#' @note Updated 2023-08-11.
#'
#' @param query `character`.
#' URL query.
#'
#' @return `list`.
#' JSON list.
#'
#' @seealso
#' - https://wormbase.org/about/userguide/for_developers/API-REST
.rest <- function(query) {
    assert(isCharacter(query))
    url <- paste("https://wormbase.org", "rest", query, sep = "/")
    json <- getJson(url)
    assert(is.list(json))
    json
}
