#' Annotation File
#'
#' @family Annotation File Functions
#'
#' @importFrom basejump initializeDirectory
#' @importFrom fs file_exists path
#' @importFrom utils download.file
#'
#' @param file Annotation file name.
#' @param version WormBase version. If `NULL`, defaults to current production
#'   release version available on the WormBase website. Legacy versions can
#'   be specified as a string (e.g. "WS262").
#' @param dir Output directory.
#'
#' @return Silently return the file path.
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
    dir <- initializeDirectory(dir)
    if (is_a_string(version)) {
        assert_all_are_matching_regex(version, versionPattern)
        fileName <- paste(
            "c_elegans",
            bioproject,
            version,
            file,
            "txt",
            "gz",
            sep = "."
        )
        url <- c(
            "ftp://ftp.wormbase.org",
            "pub",
            "wormbase",
            "releases",
            version,
            "species",
            "c_elegans",
            bioproject,
            fileName
        )
    } else {
        fileName <- paste(
            "c_elegans",
            bioproject,
            "current",
            file,
            "txt",
            "gz",
            sep = "."
        )
        url <- paste(
            "ftp://ftp.wormbase.org",
            "pub",
            "wormbase",
            "species",
            "c_elegans",
            bioproject,
            "annotation",
            file,
            fileName,
            sep = "/"
        )
    }
    destfile <- path(dir, fileName)
    names(destfile) <- file
    if (!file_exists(destfile)) {
        download.file(url = url, destfile = destfile)
    }
    invisible(destfile)
}
