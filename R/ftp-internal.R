## Updated 2021-02-17.
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



## Updated 2021-02-17.
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



## Updated 2019-08-12.
.invalidFTPFile <- function(file) {
    stop(sprintf(
        fmt = paste0(
            "Invalid FTP file detected.\n",
            "Please submit an issue on the WormBase GitHub",
            " (https://github.com/wormbase) ",
            "that the FTP file '%s' is malformed."
        ),
        basename(file)
    ))
}



## Updated 2019-07-24.
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
