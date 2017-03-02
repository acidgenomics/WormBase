#' WormBase annotation file
#'
#' Download an annotation file from the WormBase FTP server
#' @export
#' @importFrom utils download.file
#' @param file Annotation file (without extension)
wormbaseAnnotationFile <- function(file) {
    # Create the WormBase data directory, if necessary
    if (!file.exists("data-raw/wormbase")) {
        dir.create("data-raw/wormbase", recursive = TRUE)
    }

    remoteDir <- "ftp://ftp.wormbase.org/pub/wormbase/species/c_elegans/annotation/"
    version <- "canonical_bioproject.current"

    # Correct mismatches between folder and file name on WormBase FTP server
    if (file == "best_blast_hits") {
        fileName <- "best_blastp_hits.txt.gz"
    } else {
        fileName <- paste0(file, ".txt.gz")
    }

    remoteFile <- paste0(remoteDir, file, "/c_elegans.", version, ".", fileName)
    localFile <- file.path("data-raw", "wormbase", fileName)

    utils::download.file(remoteFile, localFile)
    return(localFile)
}
