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
        # version <- "current-production-release"

        # Temporary fix for buggy WS269 FTP files.
        # In the process of contacting WormBase to fix this issue.
        message(paste(
            "Current production release (WS269) FTP files are malformed.",
            "Returning WS268 release file instead.",
            sep = "\n"
        ))
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
