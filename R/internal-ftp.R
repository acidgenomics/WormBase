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



#' @importFrom basejump initializeDirectory transmit
#' @importFrom fs path_real
.transmit <- function(
    subdir,
    version = NULL,
    dir = ".",
    ...
) {
    assert_is_a_string(subdir)
    .assertFormalVersion(version)

    # Prepare remote directory path for transmit call
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
        localDir = dir,
        ...
    )

    # Check for single file match
    assert_is_of_length(file, 1L)

    file
}
