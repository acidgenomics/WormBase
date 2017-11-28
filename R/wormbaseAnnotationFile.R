#' WormBase Annotation File
#'
#' @keywords internal
#'
#' @importFrom utils download.file
#'
#' @param file Annotation file name.
#'
#' @return File path.
#' @export
wormbaseAnnotationFile <- function(file) {
    dir.create("data-raw/wormbase", recursive = TRUE, showWarnings = FALSE)
    root <- file.path(
        "ftp://ftp.wormbase.org",
        "pub",
        "wormbase",
        "species",
        "c_elegans",
        "annotation")
    version <- "canonical_bioproject.current"
    if (file == "best_blast_hits") {
        fileName <- "best_blastp_hits.txt.gz"
    } else {
        fileName <- paste0(file, ".txt.gz")
    }
    fileUrl <- file.path(
        root,
        file,
        paste0("c_elegans.", version, ".", fileName)
    )
    filePath <- file.path("data-raw", "wormbase", fileName)
    download.file(fileUrl, filePath)
    return(filePath)
}
