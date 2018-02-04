#' WormBase Annotation File
#'
#' @keywords internal
#'
#' @importFrom utils download.file
#'
#' @param file Annotation file name.
#' @param dir Directory where to save the file.
#'
#' @return File path.
#' @export
wormbaseAnnotationFile <- function(
    file,
    dir = file.path("data-raw", "wormbase")) {
    dir.create(dir, recursive = TRUE, showWarnings = FALSE)
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
    filePath <- file.path(dir, fileName)
    download.file(fileUrl, filePath)
    filePath
}
