## FIXME Can we use BiocFileCache here??
## FIXME Rethink the URL matching...can we just download directly without
## using transmit here?



#' Download an annotation file from WormBase FTP server
#'
#' @note Updated 2021-02-17.
#' @noRd
.annotationFile <- function(stem, version = NULL) {
    subdir <- pasteURL("species", "c_elegans", .bioproject, "annotation")
    .transmit(
        stem = stem,
        subdir = subdir,
        version = version
    )
}



#' Download an assembly file from WormBase FTP server
#'
#' @note Updated 2021-02-17.
#' @noRd
.assemblyFile <- function(...) {
    .transmit(
        subdir = pasteURL(
            "species",
            "c_elegans",
            .bioproject
        ),
        ...
    )
}



#' Transmit file from WormBase FTP server
#'
#' @note Updated 2021-02-17.
#' @noRd
.transmit <- function(
    stem,
    subdir,
    version = NULL
) {
    assert(
        isString(stem),
        isString(subdir),
        .isVersion(version)
    )
    if (is.null(version)) {
        version <- currentRelease()
        version2 <- "current-production-release"
    } else {
        version2 <- version
    }
    url <- pasteURL(
        "ftp.wormbase.org",
        "pub",
        "wormbase",
        "releases",
        version2,
        subdir,
        paste(
            "c_elegans",
            .bioproject,
            version,
            stem,
            sep = "."
        ),
        protocol = "ftp"
    )
    file <- .cacheIt(url)
    assert(isAFile(file))
    file
}
