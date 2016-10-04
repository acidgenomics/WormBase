# @importFrom utils download.file
wormbaseFtpFile <- function(file) {
    annotation <- "ftp://ftp.wormbase.org/pub/wormbase/species/c_elegans/annotation/"
    version <- "canonical_bioproject.current"
    if (file == "best_blast_hits") {
        fileName <- "best_blastp_hits.txt.gz"
    } else {
        fileName <- paste0(file, ".txt.gz")
    }
    fileUrl <- paste0(annotation, file, "/c_elegans.", version, ".", fileName)
    filePath <- file.path("data-raw", "wormbase", fileName)
    if (!file.exists(filePath)) {
        utils::download.file(fileUrl, filePath)
    }
    return(filePath)
}
