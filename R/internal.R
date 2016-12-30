#' @importFrom utils download.file
.onLoad <- function(libname, pkgname) {
    envir = asNamespace("worminfo")

    # Download source data from the `data` branch on GitHub:
    assign("geneAnnotation", tempfile(), envir = envir)
    utils::download.file("http://worminfo.steinbaugh.com/data/geneAnnotation.rda",
                         get("geneAnnotation", envir = envir), quiet = TRUE)
    load(get("geneAnnotation", envir = envir), envir = envir)

    assign("rnaiAnnotation", tempfile(), envir = envir)
    utils::download.file("http://worminfo.steinbaugh.com/data/rnaiAnnotation.rda",
                         get("rnaiAnnotation", envir = envir),
                         quiet = TRUE)
    load(get("rnaiAnnotation", envir = envir), envir = envir)

    assign("build", tempfile(), envir = envir)
    utils::download.file("http://worminfo.steinbaugh.com/data/build.rda",
                         get("build", envir = envir),
                         quiet = TRUE)
    load(get("build", envir = envir), envir = envir)
}



.onAttach <- function(libname, pkgname) {
    packageStartupMessage(
        paste("Annotations:",
              paste(build$ensembl,
                    build$panther,
                    build$wormbase,
                    sep = ", "),
              paste0("(", build$date, ")"),
              sep = " ")
    )
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
