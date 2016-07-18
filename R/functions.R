#' Match biomaRt output with WormBase Gene IDs
#'
#' @param df
#'
#' @return data.frame with all WormBase Gene IDs
#' @export
bm2wb <- function(df) {
  colnames(df) <- seqcloudR::camel(colnames(df))
  rownames(df) <- df$ensemblGeneId
  df <- geneIdRows(df)
  return(df)
}


#' Set number of rows to Wormbase Gene IDs
#'
#' @param df
#'
#' @return data.frame with all WormBase Gene IDs
#' @export
geneIdRows <- function(df) {
  vec <- geneIds
  df <- df[vec, ]
  rownames(df) <- rownames(vec)
  return(df)
}


#' ORF metadata matching
#'
#' @param orf ORF character vector
#'
#' @return data.frame
#' @export
getOrfMetadata <- function(orf) {
  # Since there are duplicate ORFs per well, loop from metadataOrf
  list <- list()
  list <- lapply(seq(along = orf), function(i) {
    # Strip out isoform (included in some Ahringer clones)
    orfSearch <- gsub("\\.[a-z]{1}$", "", orf[i])
    metadataOrf[orfSearch, ]
  })
  # Converting to a data frame here will take a while
  df <- data.frame(do.call("rbind", list))
  return(df)
}


#' Bind ORF metadata to data.frame
#'
#' @param df data.frame with `orf` column
#'
#' @return data.frame with metadataOrf information
#' @export
bindOrfMetadata <- function(df) {
  df <- cbind(df, getOrfMetadata(df$orf))
  df <- df[, unique(names(df))]
  return(df)
}


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
    download.file(fileUrl, filePath)
  }

  return(filePath)

  # tempfile method:
  #! temp <- tempfile(fileext = ".txt.gz")
  #! download.file(fileUrl, temp)
}
