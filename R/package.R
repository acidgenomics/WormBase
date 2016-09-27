.onAttach <- function(libname, pkgname) {
    packageStartupMessage("Source data: https://github.com/steinbaugh/worminfo")
}

#' @importFrom utils download.file
.onLoad <- function(libname, pkgname) {
    envir = asNamespace("worminfo")
    # Download source data from GitHub repo:
    # geneSource
    assign("geneSource", tempfile(), envir = envir)
    utils::download.file("https://raw.githubusercontent.com/steinbaugh/worminfo/master/data/geneSource.rda",
                         get("geneSource", envir = envir),
                         quiet = TRUE)
    load(get("geneSource", envir = envir), envir = envir)
    # rnaiSource
    assign("rnaiSource", tempfile(), envir = envir)
    utils::download.file("https://raw.githubusercontent.com/steinbaugh/worminfo/master/data/rnaiSource.rda",
                         get("rnaiSource", envir = envir),
                         quiet = TRUE)
    load(get("rnaiSource", envir = envir), envir = envir)
}

# dot global for magrittr piping
utils::globalVariables(c("."))
