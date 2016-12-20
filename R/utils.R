#' camelCase
#'
#' @import magrittr
#'
#' @param string \code{string}.
#'
#' @return \code{string} with camelCase formatting.
camel <- function(string) {
    string %>%
        # Convert non-alphanumeric characters to underscores:
        gsub("[^[:alnum:]]", "_", .) %>%
        # Multiple underscores to single:
        gsub("[_]+", "_", .) %>%
        # Remove leading or trailing underscores:
        gsub("(^_|_$)", "", .) %>%
        # Convert acronymes to Mixed Case:
        gsub("([A-Z]{1})([A-Z]+)", "\\1\\L\\2", ., perl = TRUE) %>%
        # Lowercase first letter:
        gsub("(^[A-Z]{1})", "\\L\\1", ., perl = TRUE) %>%
        # Convert snake_case to camelCase
        gsub("_(\\w?)", "\\U\\1", ., perl = TRUE)
}



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



#' Set names as camelCase
#'
#' @importFrom magrittr set_names
#'
#' @param data \code{data.frame}, \code{list}, or \code{tibble}
#'
#' @return data Same data but with reformatted camelCase names
setNamesCamel <- function(data) {
    data %>%
        magrittr::set_names(., camel(names(.)))
}



#' toString call that only outputs uniques.
#'
#' @import magrittr
#'
#' @param x vector.
#'
#' @return string vector.
toStringUnique <- function(x) {
    x %>%
        unique %>%
        sort %>%
        toString %>%
        gsub("NA,\\s|,\\sNA", "", .)
}
