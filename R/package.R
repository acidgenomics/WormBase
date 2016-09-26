.onAttach <- function(libname, pkgname) {
    packageStartupMessage("Source data: https://github.com/steinbaugh/worminfo")
}


#' @importFrom utils download.file
.onLoad <- function(libname, pkgname) {
    envir = asNamespace("worminfo")

    # Download source data from GitHub repo:
    assign("geneData", tempfile(), envir = envir)
    utils::download.file("https://raw.githubusercontent.com/steinbaugh/worminfo/master/data/geneData.rda",
                         get("geneData", envir = envir),
                         quiet = TRUE)
    load(get("geneData", envir = envir), envir = envir)

    assign("rnaiData", tempfile(), envir = envir)
    utils::download.file("https://raw.githubusercontent.com/steinbaugh/worminfo/master/data/rnaiData.rda",
                         get("rnaiData", envir = envir),
                         quiet = TRUE)
    load(get("rnaiData", envir = envir), envir = envir)
}
