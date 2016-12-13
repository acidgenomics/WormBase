#' @importFrom utils download.file
.onLoad <- function(libname, pkgname) {
    envir = asNamespace("worminfo")

    # Download source data from the `data` branch on GitHub:
    # geneAnnotations
    assign("geneAnnotation", tempfile(), envir = envir)
    utils::download.file("https://github.com/steinbaugh/worminfo/raw/dev/data/geneAnnotation.rda",
        get("geneAnnotation", envir = envir), quiet = TRUE)
    load(get("geneAnnotation", envir = envir), envir = envir)

    # rnaiAnnotations
    assign("rnaiAnnotation", tempfile(), envir = envir)
    utils::download.file("https://github.com/steinbaugh/worminfo/raw/dev/data/rnaiAnnotation.rda",
                         get("rnaiAnnotation", envir = envir),
                         quiet = TRUE)
    load(get("rnaiAnnotation", envir = envir), envir = envir)


    # Download the source data build information:
    assign("build", tempfile(), envir = envir)
    utils::download.file("https://github.com/steinbaugh/worminfo/raw/dev/data/build.rda",
                         get("build", envir = envir),
                         quiet = TRUE)
    load(get("build", envir = envir), envir = envir)
}

.onAttach <- function(libname, pkgname) {
    packageStartupMessage(
        paste(paste0("Annotations ", build$date, ":"),
              paste(build$wormbase, build$ensembl, build$panther, sep = ", "))
    )
}
