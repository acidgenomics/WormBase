## FIXME Can we use BiocFileCache here??
## FIXME Rethink the URL matching...can we just download directly without
## using transmit here?



#' Download an annotation file from WormBase FTP server
#'
#' @note Updated 2021-02-17.
#' @noRd
.annotationFile <- function(...) {
    .transmit(
        subdir = pasteURL(
            "species",
            "c_elegans",
            .bioproject,
            "annotation"
        ),
        ...
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
#' @note Updated 2019-07-24.
#' @noRd
.transmit <- function(
    subdir,
    version = NULL,
    ...
) {
    assert(
        isString(subdir),
        .isVersion(version)
    )
    ## Prepare remote directory path for transmit call.
    if (is.null(version)) {
        version <- "current-production-release"
    }
    releaseDir <- pasteURL(
        "ftp.wormbase.org",
        "pub",
        "wormbase",
        "releases",
        version,
        protocol = "ftp"
    )
    remoteDir <- pasteURL(releaseDir, subdir)
    file <- transmit(
        remoteDir = remoteDir,
        localDir = tempdir(),
        ...
    )
    ## Check for single file match.
    assert(isString(file))
    unname(file)
}
