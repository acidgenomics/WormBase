#' Download an annotation file from WormBase FTP server
#'
#' @note Updated 2021-02-17.
#' @noRd
.annotationFile <-
    function(stem, release) {
        .transmit(
            basename = paste(
                "c_elegans",
                .bioproject,
                "{{release}}",
                stem,
                sep = "."
            ),
            subdir = pasteURL(
                "species",
                "c_elegans",
                .bioproject,
                "annotation"
            ),
            release = release
        )
    }



#' Download an assembly file from WormBase FTP server
#'
#' @note Updated 2021-02-17.
#' @noRd
.assemblyFile <-
    function(stem, release) {
        .transmit(
            basename = paste(
                "c_elegans",
                .bioproject,
                "{{release}}",
                stem,
                sep = "."
            ),
            subdir = pasteURL("species", "c_elegans", .bioproject),
            release = release
        )
    }



#' Ontology file from WormBase FTP server
#'
#' @note Updated 2021-02-17.
#' @noRd
.ontologyFile <-
    function(stem, release) {
        .transmit(
            basename = paste0(stem, ".{{release}}.wb"),
            subdir = "ONTOLOGY",
            release = release
        )
    }



#' Transmit file from WormBase FTP server
#'
#' @note Updated 2021-02-17.
#' @noRd
.transmit <-
    function(basename,
             subdir,
             release) {
        assert(
            isString(basename),
            isString(subdir),
            .isRelease(release)
        )
        if (is.null(release)) {
            release <- currentRelease()
            release2 <- "current-production-release"
        } else {
            release2 <- release
        }
        url <- pasteURL(
            "ftp.wormbase.org",
            "pub",
            "wormbase",
            "releases",
            release2,
            subdir,
            basename,
            protocol = "ftp"
        )
        url <- gsub(
            pattern = "{{release}}",
            replacement = release,
            x = url,
            fixed = TRUE
        )
        file <- .cacheIt(url)
        assert(isAFile(file))
        file
    }
