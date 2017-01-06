#' @importFrom utils download.file
#' @keywords internal
.onLoad <- function(libname, pkgname) {
    data <- c("build",
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
