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
