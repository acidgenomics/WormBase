library(seqcloudR)
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

  wormbaseDownload <- tempfile(fileext = ".txt.gz")
  download.file(fileUrl, wormbaseDownload)

  assignName <- camel(file)
  assign(assignName, wormbaseDownload, envir = .GlobalEnv)
}
