## FIXME RENAME VERSION TO RELEASE.



#' Download an annotation file from WormBase FTP server
#'
#' @note Updated 2021-02-17.
#' @noRd
.annotationFile <-
    function(stem, version) {
        .transmit(
            basename = paste(
                "c_elegans",
                .bioproject,
                "{{version}}",
                stem,
                sep = "."
            ),
            subdir = pasteURL(
                "species",
                "c_elegans",
                .bioproject,
                "annotation"
            ),
            version = version
        )
    }



#' Download an assembly file from WormBase FTP server
#'
#' @note Updated 2021-02-17.
#' @noRd
.assemblyFile <-
    function(stem, version) {
        .transmit(
            basename = paste(
                "c_elegans",
                .bioproject,
                "{{version}}",
                stem,
                sep = "."
            ),
            subdir = pasteURL("species", "c_elegans", .bioproject),
            version = version
        )
    }



#' Ontology file from WormBase FTP server
#'
#' @note Updated 2021-02-17.
#' @noRd
.ontologyFile <-
    function(stem, version) {
        .transmit(
            basename = paste0(stem, ".{{version}}.wb"),
            subdir = "ONTOLOGY",
            version = version
        )
    }



#' Transmit file from WormBase FTP server
#'
#' @note Updated 2021-02-17.
#' @noRd
.transmit <- function(
    basename,
    subdir,
    version
) {
    assert(
        isString(basename),
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
        basename,
        protocol = "ftp"
    )
    url <- gsub(
        pattern = "{{version}}",
        replacement = version,
        x = url,
        fixed = TRUE
    )
    file <- .cacheIt(url)
    assert(isAFile(file))
    file
}
