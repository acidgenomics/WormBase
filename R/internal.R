#' @importFrom utils download.file
.onLoad <- function(libname, pkgname) {
    remoteDir <- "http://worminfo.steinbaugh.com/data"
    current <- readLines(file.path(remoteDir, "current.txt"))
    if (is.null(current)) {
        stop("Failed to obtain current build.")
    }
    cacheDir <- file.path(Sys.getenv("HOME"), "cache", "worminfo")
    if (!file.exists(cacheDir)) {
        dir.create(cacheDir, recursive = TRUE)
    }
    # Check build date of cache
    if (file.exists(file.path(cacheDir, "build.rda"))) {
        load(file.path(cacheDir, "build.rda"))
        if (build$date == current) {
            download <- FALSE
        } else {
            download <- TRUE
        }
    } else {
        download <- TRUE
    }
    data <- c("annotation", "build")
    for (a in 1:length(data)) {
        localFile <- file.path(cacheDir, paste0(data[a], ".rda"))
        if (isTRUE(download) | !file.exists(localFile)) {
            remoteFile <- file.path(remoteDir, current, paste0(data[a], ".rda"))
            utils::download.file(remoteFile, localFile, quiet = TRUE)
        }
        load(localFile, envir = asNamespace("worminfo"))
    }
}



#' Pipe operator
#' @export
#' @importFrom magrittr %>%
#' @keywords internal
#' @name %>%
#' @rdname pipe
#' @usage lhs \%>\% rhs
NULL



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



dataRaw <- function(data) {
    for (a in 1:length(data)) {
        if (!file.exists(paste0("data/", data[a], ".rda"))) {
            source(paste0("data-raw/", data[a], ".R"))
        } else {
            load(paste0("data/", data[a], ".rda"), envir = globalenv())
        }
    }
}



#' Default columns for \code{select}
#' @param defaultCol Default columns
defaultCol <- c("gene", "sequence", "name")



fixNA <- function(string) {
    gsub("^$|^NA$", NA, string)
}



#' @importFrom dplyr funs
funs <- function(...) {
    dplyr::funs(...)
}



grepString <- function(identifier) {
    identifier %>%
        paste0(
            # Unique:
            "^", ., "$",
            "|",
            # Beginning of list:
            "^", ., ",",
            "|",
            # Middle of list:
            "\\s", ., ",",
            "|",
            # End of list:
            "\\s", ., "$")
}



removeIsoform <- function(sequence) {
    grep <- "^([A-Z0-9]+)\\.([0-9]+)[a-z]$"
    if (any(grepl(grep, sequence))) {
        message("Sequence identifiers should not end with an isoform letter.")
        gsub(grep, "\\1.\\2", sequence)
    } else {
        sequence
    }
}



#' @importFrom httr content content_type_json GET user_agent
rest <- function(url) {
    httr::GET(paste0("http://api.wormbase.org/rest/", url),
              config = httr::content_type_json(),
              user_agent = httr::user_agent(userAgent)) %>%
        httr::content(.)
}



#' @importFrom stats setNames
setNamesCamel <- function(data) {
    data %>%
        stats::setNames(., camel(names(.)))
}



#' Summarize rows using toString
#' @export
#' @importFrom tibble as_tibble
#' @importFrom dplyr mutate_each summarise_each
#' @param tibble tibble
toStringSummarize <- function(tibble) {
    tibble %>%
        tibble::as_tibble(.) %>%
        dplyr::summarise_each(funs(toStringUnique)) %>%
        dplyr::mutate_each(funs(fixNA))
}



toStringSortUnique <- function(vector) {
    vector %>%
        unique %>%
        sort %>%
        toString %>%
        gsub("NA,\\s|,\\sNA", "", .)
}



toStringUnique <- function(vector) {
    vector %>%
        unique %>%
        toString %>%
        gsub("NA,\\s|,\\sNA", "", .)
}



#' @importFrom stats na.omit
uniqueIdentifier <- function(identifier) {
    if (missing(identifier)) {
        stop("An identifier is required.")
    } else if (!is.character(identifier)) {
        stop("Identifier must be a character vector.")
    }
    # Fix WBGene capitalization and alert user if necessary:
    grep <- "^(WBGENE|WBgene|Wbgene|wbgene)(\\d{8})$"
    if (any(grepl(grep, identifier))) {
        message("WormBase gene identifiers should begin with `WBGene`.")
        identifier <- gsub(grep, "WBGene\\2", identifier)
    }
    identifier %>%
        stats::na.omit(.) %>%
        unique %>%
        sort
}



#' User agent for REST API queries
#' @param userAgent User agent
userAgent <- "https://github.com/steinbaugh/worminfo"



# Dot global needed for piping:
utils::globalVariables(c("."))



#' @importFrom utils download.file
wormbaseAnnotationFile <- function(file) {
    if (!file.exists("data-raw/wormbase")) {
        dir.create("data-raw/wormbase", recursive = TRUE)
    }
    root <- "ftp://ftp.wormbase.org/pub/wormbase/species/c_elegans/annotation/"
    version <- "canonical_bioproject.current"
    if (file == "best_blast_hits") {
        fileName <- "best_blastp_hits.txt.gz"
    } else {
        fileName <- paste0(file, ".txt.gz")
    }
    fileUrl <- paste0(root, file, "/c_elegans.", version, ".", fileName)
    filePath <- file.path("data-raw", "wormbase", fileName)
    if (!file.exists(filePath)) {
        utils::download.file(fileUrl, filePath)
    }
    return(filePath)
}
