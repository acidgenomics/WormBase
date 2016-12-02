.onAttach <- function(libname, pkgname) {
    packageStartupMessage(
        paste(paste0("Annotations Build ", build$date),
              paste(build$wormbase,
                    build$ensembl,
                    build$panther,
                    sep = ", "),
              "https://github.com/steinbaugh/worminfo", sep = "\n")
    )
}

#' @importFrom utils download.file
.onLoad <- function(libname, pkgname) {
    envir = asNamespace("worminfo")

    # Download source data from the `data` branch on GitHub:
    # geneAnnotations
    assign("geneAnnotations", tempfile(), envir = envir)
    utils::download.file("https://github.com/steinbaugh/worminfo/raw/data/data/geneAnnotations.rda",
        get("geneAnnotations", envir = envir), quiet = TRUE)
    load(get("geneAnnotations", envir = envir), envir = envir)

    # rnaiAnnotations
    assign("rnaiAnnotations", tempfile(), envir = envir)
    utils::download.file("https://github.com/steinbaugh/worminfo/raw/data/data/rnaiAnnotations.rda",
                         get("rnaiAnnotations", envir = envir),
                         quiet = TRUE)
    load(get("rnaiAnnotations", envir = envir), envir = envir)


    # Download the source data build information:
    assign("build", tempfile(), envir = envir)
    utils::download.file("https://github.com/steinbaugh/worminfo/raw/data/data/build.rda",
                         get("build", envir = envir),
                         quiet = TRUE)
    load(get("build", envir = envir), envir = envir)
}
