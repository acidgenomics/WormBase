# Dot global needed for \code{pipe} function:
utils::globalVariables(c("."))



# #' @keywords internal
# .onAttach <- function(libname, pkgname) {
#     packageStartupMessage(
#         paste("Annotations:",
#               paste(build$ensembl,
#                     build$panther,
#                     build$wormbase,
#                     sep = ", "),
#               paste0("(", build$date, ")"),
#               sep = " ")
#     )
# }



#' @importFrom utils download.file
#' @keywords internal
.onLoad <- function(libname, pkgname) {
    data <- c("build",
              "cherrypickAnnotation",
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
#' @export
#' @keywords general
#' @param string \code{string}
#' @return \code{string} with camelCase formatting
#'
#' @examples
#' camel("RNAi clone")
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



#' Collapse rows in a tibble
#'
#' @export
#' @importFrom dplyr mutate_each summarise_each
#' @importFrom tibble as_tibble
#' @keywords general
#' @param tibble Long \code{tibble}
#' @return Collapsed \code{tibble}
collapse <- function(tibble) {
    tibble %>%
        tibble::as_tibble(.) %>%
        dplyr::summarise_each(funs(toStringUnique)) %>%
        dplyr::mutate_each(funs(fixNA))
}



#' Source data-raw R script if necessary then load data binary
#'
#' @keywords internal
#' @param data Data filename
dataRaw <- function(data) {
    for (a in 1:length(data)) {
        if (!file.exists(paste0("data/", data[a], ".rda"))) {
            source(paste0("data-raw/", data[a], ".R"))
        } else {
            load(paste0("data/", data[a], ".rda"), envir = globalenv())
        }
    }
}



#' Fix empty and "NA" character strings
#'
#' @keywords internal
#' @param string \code{string} missing \code{NA}.
#' @return \code{string} containing \code{NA}
#'
#' @examples
#' fixNA(c(1, "x", "", "NA"))
fixNA <- function(string) {
    gsub("^$|^NA$", NA, string)
}



#' WormBase REST API query
#'
#' @importFrom httr content content_type_json GET user_agent
#' @keywords internal
#' @param url URL
rest <- function(url) {
    httr::GET(paste0("http://api.wormbase.org/rest/", url),
              config = httr::content_type_json(),
              user_agent = httr::user_agent(ua)) %>%
        httr::content(.)
}



#' Simple columns
#'
#' @keywords internal
#' @param simpleCol Simple columns
simpleCol <- c("gene", "sequence", "name")



#' Set names as camelCase
#'
#' @export
#' @importFrom magrittr set_names
#' @keywords general
#' @param data \code{data.frame}, \code{list}, or \code{tibble}
#' @return data Same data but with reformatted camelCase names
setNamesCamel <- function(data) {
    data %>%
        magrittr::set_names(., camel(names(.)))
}



#' toString call that outputs uniques
#'
#' @export
#' @keywords general
#' @param vector \code{vector}
#' @return Unique \code{string}
toStringUnique <- function(vector) {
    vector %>%
        unique %>%
        toString %>%
        gsub("NA,\\s|,\\sNA", "", .)
}



#' toString call that outputs sorted uniques
#'
#' @export
#' @keywords general
#' @param vector \code{vector}
#' @return Sorted unique \code{string}
toStringSortUnique <- function(vector) {
    vector %>%
        unique %>%
        sort %>%
        toString %>%
        gsub("NA,\\s|,\\sNA", "", .)
}



#' User agent for REST API calls
#'
#' @keywords internal
#' @param ua User agent
ua <- "https://github.com/steinbaugh/worminfo"
