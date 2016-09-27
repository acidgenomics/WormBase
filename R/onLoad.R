# .onAttach <- function(libname, pkgname) {
#     packageStartupMessage("Source data: https://github.com/steinbaugh/worminfo/tree/data")
# }

#' @importFrom utils download.file
.onLoad <- function(libname, pkgname) {
    envir = asNamespace("worminfo")
    # Download source data from the `data` branch on GitHub:
    # geneSource
    assign("geneSource", tempfile(), envir = envir)
    utils::download.file("https://raw.githubusercontent.com/steinbaugh/worminfo/data/data/geneSource.rda",
                         get("geneSource", envir = envir),
                         quiet = TRUE)
    load(get("geneSource", envir = envir), envir = envir)
    # rnaiSource
    assign("rnaiSource", tempfile(), envir = envir)
    utils::download.file("https://raw.githubusercontent.com/steinbaugh/worminfo/data/data/rnaiSource.rda",
                         get("rnaiSource", envir = envir),
                         quiet = TRUE)
    load(get("rnaiSource", envir = envir), envir = envir)
}
