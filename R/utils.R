#' Pipe operator
#'
#' @name %>%
#' @rdname pipe
#' @keywords internal
#' @export
#' @importFrom magrittr %>%
#' @usage lhs \%>\% rhs
NULL



#' camelCase
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



#' Load data and source if necessary
#'
#' @param data Data files
#'
#' @export
loadData <- function(data) {
    for (a in 1:length(data)) {
        if (!file.exists(paste0("data/", data[a], ".rda"))) {
            source(paste0("data-raw/", data[a], ".R"))
        } else {
            load(paste0("data/", data[a], ".rda"), envir = globalenv())
        }
    }
}



#' Collapse rows in a data.frame.
#'
#' @importFrom dplyr funs mutate_each summarise_each
#'
#' @param tibble long tibble.
#'
#' @return collapsed tibble.
#' @export
collapse <- function(tibble) {
    tibble %>%
        dplyr::summarise_each(funs(toStringUnique)) %>%
        dplyr::mutate_each(funs(fixNA))
}



#' Fix empty and "NA" character strings.
#'
#' @param a Values missing \code{NA}.
#'
#' @return Values containing \code{NA}.
#' @export
#'
#' @examples
#' fixNA(c(1, "x", "", "NA"))
fixNA <- function(a) {
    gsub("^$|^NA$", NA, a)
}



#' WormBase REST API query
#'
#' @importFrom httr content content_type_json GET user_agent
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
