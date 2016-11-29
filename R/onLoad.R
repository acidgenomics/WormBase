.onAttach <- function(libname, pkgname) {
    packageStartupMessage(
        paste("Downloading current data build...",
              "https://github.com/steinbaugh/worminfo/tree/data",
              sep = "\n")
    )
}

#' @importFrom utils download.file
.onLoad <- function(libname, pkgname) {
    envir = asNamespace("worminfo")

    # Download source data from the `data` branch on GitHub:
    # geneSource
    assign("geneSource", tempfile(), envir = envir)
    utils::download.file("https://github.com/steinbaugh/worminfo/raw/data/data/geneSource.rda",
                         get("geneSource", envir = envir),
                         quiet = TRUE)
    load(get("geneSource", envir = envir), envir = envir)

    # rnaiSource
    assign("rnaiSource", tempfile(), envir = envir)
    utils::download.file("https://github.com/steinbaugh/worminfo/raw/data/data/rnaiSource.rda",
                         get("rnaiSource", envir = envir),
                         quiet = TRUE)
    load(get("rnaiSource", envir = envir), envir = envir)


    # Download the source data build information:
    assign("build", tempfile(), envir = envir)
    utils::download.file("https://github.com/steinbaugh/worminfo/raw/data/data/build.rda",
                         get("build", envir = envir),
                         quiet = TRUE)
    load(get("build", envir = envir), envir = envir)
}
