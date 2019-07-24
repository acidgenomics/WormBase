## Updated 2019-07-24.
.annotationFile <- function(...) {
    .transmit(
        subdir = paste(
            "species",
            "c_elegans",
            bioproject,
            "annotation",
            sep = "/"
        ),
        ...
    )
}



## Updated 2019-07-24.
.assemblyFile <- function(...) {
    .transmit(
        subdir = paste(
            "species",
            "c_elegans",
            bioproject,
            sep = "/"
        ),
        ...
    )
}



## Updated 2019-07-24.
.invalidFTPFile <- function(file) {
    stop(paste0(
        "Failed to detect any valid gene identifiers.\n",
        "Please file an issue on GitHub that file ",
        "`", basename(file), "` ",
        "is malformed on the WormBase FTP server."
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
    releaseDir <- paste(
        "ftp://ftp.wormbase.org",
        "pub",
        "wormbase",
        "releases",
        version,
        sep = "/"
    )
    remoteDir <- paste(releaseDir, subdir, sep = "/")
    file <- transmit(
        remoteDir = remoteDir,
        localDir = tempdir(),
        ...
    )
    ## Check for single file match.
    assert(isString(file))
    unname(file)
}
