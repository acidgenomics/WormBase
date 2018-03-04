#' Annotation File
#'
#' @family Annotation File Functions
#'
#' @importFrom basejump initializeDirectory transmit
#' @importFrom fs file_exists path path_real
#' @importFrom utils download.file
#'
#' @inheritParams general
#'
#' @return Invisible file path vector.
#' @export
#'
#' @examples
#' # Current
#' current <- annotationFile("geneIDs")
#' print(current)
#'
#' # Versioned
#' versioned <- annotationFile("geneIDs", version = "WS262")
#' print(versioned)
#'
#' # Clean up
#' file_exists(c(current, versioned))
#' file_delete(c(current, versioned))
annotationFile <- function(
    file,
    version = NULL,
    dir = "."
) {
    assert_is_a_string(file)
    .assertFormalVersion(version)
    dir <- initializeDirectory(dir)
    if (is.null(version)) {
        version <- "current-production-release"
    }
    remoteDir <- paste(
        "ftp://ftp.wormbase.org",
        "pub",
        "wormbase",
        "releases",
        version,
        "species",
        "c_elegans",
        bioproject,
        "annotation",
        sep = "/"
    )
    return <- transmit(
        remoteDir = remoteDir,
        localDir = dir,
        pattern = file
    )
    assert_is_of_length(return, 1L)
    length(return)
    return <- path_real(as.character(return))
    names(return) <- file
    return
}
