library(seqcloudR)
wormbaseFile <- function(file) {
  assignName <- camel(file)

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
  download.file(fileUrl, filePath)
  assign(assignName, filePath, envir = .GlobalEnv)

  # tempfile method:
  #! temp <- tempfile(fileext = ".txt.gz")
  #! download.file(fileUrl, temp)
  #! assign(assignName, temp, envir = .GlobalEnv)
}
