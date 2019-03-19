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



.transmit <- function(
    subdir,
    version = NULL,
    dir = ".",
    ...
) {
    assert(
        isString(subdir),
        .isVersion(version),
        isString(dir)
    )

    # Prepare remote directory path for transmit call.
    if (is.null(version)) {
        # WS269 files are currently buggy.
        # version <- "current-production-release"
        version <- "WS268"
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

    file <- transmit(remoteDir = remoteDir, localDir = dir, ...)

    # Check for single file match.
    assert(isString(file))

    file
}
