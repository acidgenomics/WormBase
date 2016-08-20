#' Download a file from WormBase
#'
#' @param file FTP file request
#'
#' @return File path of download
#' @export
wormbaseFile <- function(file) {
  annotation <-
    "ftp://ftp.wormbase.org/pub/wormbase/species/c_elegans/annotation/"
  version <- "canonical_bioproject.current"

  if (file == "best_blast_hits") {
    fileName <- "best_blastp_hits.txt.gz"
  } else {
    fileName <- paste0(file, ".txt.gz")
  }
  fileUrl <- paste0(annotation, file, "/c_elegans.", version, ".", fileName)

  # data-raw method:
  filePath <- file.path("data-raw", fileName)

  if (!file.exists(filePath)) {
    utils::download.file(fileUrl, filePath)
  }

  # tempfile method:
  #! temp <- tempfile(fileext = ".txt.gz")
  #! utils::download.file(fileUrl, temp)

  return(filePath)
}
