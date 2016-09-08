#' WormBase FTP server file download
#' @param request WormBase FTP server file request.
#' @return Local file path of downloaded file.
#' @export
wormbaseFile <- function(request) {
    annotation <- "ftp://ftp.wormbase.org/pub/wormbase/species/c_elegans/annotation/"
    version <- "canonical_bioproject.current"
    if (request == "best_blast_hits") {
        fileName <- "best_blastp_hits.txt.gz"
    } else {
        fileName <- paste0(request, ".txt.gz")
    }
    fileUrl <- paste0(annotation, request, "/c_elegans.", version, ".", fileName)
    filePath <- file.path("data-raw", "wormbase", fileName)
    if (!file.exists(filePath)) {
        utils::download.file(fileUrl, filePath)
    }
    return(filePath)
}
