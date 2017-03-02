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
