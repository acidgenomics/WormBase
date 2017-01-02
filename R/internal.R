# Needed for piping
utils::globalVariables(c("."))



#' @importFrom utils download.file
.onLoad <- function(libname, pkgname) {
    data <- c("build",
              "eggnogAnnotation",
              "eggnogCategory",
              "geneAnnotation",
              "rnaiAnnotation")
    envir = asNamespace("worminfo")

    # Download source data from steinbaugh.com:
    for (a in 1:length(data)) {
        assign(data[a], tempfile(), envir = envir)
        utils::download.file(paste0("http://worminfo.steinbaugh.com/data/", data[a], ".rda"),
                             get(data[a], envir = envir),
                             quiet = TRUE)
        load(get(data[a], envir = envir), envir = envir)
    }
}



#' Pipe operator
#'
#' @export
#' @importFrom magrittr %>%
#' @keywords internal
#' @name %>%
#' @rdname pipe
#' @usage lhs \%>\% rhs
NULL



#' camelCase
#'
#' @keywords internal
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
#' @keywords internal
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
#' @keywords internal
collapse <- function(tibble) {
    tibble %>%
        dplyr::summarise_each(funs(toStringUnique)) %>%
        dplyr::mutate_each(funs(fixNA))
}



#' Fix empty and "NA" character strings.
#'
#' @keywords internal
fixNA <- function(a) {
    gsub("^$|^NA$", NA, a)
}



#' WormBase REST API query
#'
#' @importFrom httr content content_type_json GET user_agent
#' @keywords internal
rest <- function(url) {
    httr::GET(paste0("http://api.wormbase.org/rest/", url),
              config = httr::content_type_json(),
              user_agent = httr::user_agent(ua)) %>%
        httr::content(.)
}



#' Simple columns
#' @param simpleCol Simple columns
simpleCol <- c("gene", "sequence", "name")



#' Set names as camelCase
#'
#' @importFrom magrittr set_names
#' @keywords internal
setNamesCamel <- function(data) {
    data %>%
        magrittr::set_names(., camel(names(.)))
}



#' toString call that only outputs uniques.
#'
#' @keywords internal
toStringUnique <- function(x) {
    x %>%
        unique %>%
        sort %>%
        toString %>%
        gsub("NA,\\s|,\\sNA", "", .)
}



#' User agent
#' @param ua User agent
ua <- "https://github.com/steinbaugh/worminfo"
