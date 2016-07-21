colNamesSimple <-
  c("geneId",
    "orf",
    "publicName"
    )

colNamesReport <-
  c(colNamesSimple,
    "wormbaseGeneOtherIds",
    "wormbaseGeneClassDescription",
    "wormbaseConciseDescription",
    "wormbaseBlastpEnsemblGeneName",
    "wormbaseBlastpEnsemblDescription",
    "wormbaseStatus",
    "ensemblGeneBiotype",
    "pantherFamilyName",
    "pantherSubfamilyName"
  )


#' Match Ensembl/biomaRt output with WormBase Gene IDs
#'
#' @param df data.frame output from biomaRt
#'
#' @return data.frame with all WormBase Gene IDs
ensembl2wormbase <- function(df) {
  colnames(df) <- seqcloudr::camel(colnames(df))
  rownames(df) <- df$ensemblGeneId
  df <- geneIdRows(df)
  return(df)
}


#' Set number of rows to Wormbase Gene IDs
#'
#' @param df data.frame without all WormBase identifiers
#'
#' @return data.frame with all WormBase identifiers
geneIdRows <- function(df) {
  vec <- geneIds
  df <- df[vec, ]
  rownames(df) <- rownames(vec)
  return(df)
}


#' Annotation metadata
#'
#' @param rowNames Identifier vector
#' @param id Identifier type (geneID, orf, publicName)
#' @param type Output type (report, simple)
#'
#' @return metadata data.frame
#' @export
metadata <- function(rowNames = NULL, id = "geneId", type = "simple") {
  df <- metadataMaster
  rownames(df) <- df$geneId

  # Subset columns
  if (type == "report") {
    df <- df[, colNamesReport]
  } else {
    df <- df[, colNamesSimple]
  }

  # orf matching
  if (id == "orf") {
    if (!is.null(rowNames)) {
      # Strip isoforms from ORF
      rowNames <- gsub("\\.[a-z]{1}$", "", rowNames)
    }
    df <- subset(df, !is.na(df$orf))
    df <- subset(df, !duplicated(df$orf))
    rownames(df) <- df$orf
  }

  # publicName matching
  if (id == "publicName") {
    df <- subset(df, !is.na(df$publicName))
    df <- subset(df, !duplicated(df$publicName))
    rownames(df) <- df$publicName
  }

  # Subset rows
  if (!is.null(rowNames)) {
    df <- df[rowNames, ]
  }

  return(df)
}


#' Bind metadata to data.frame
#'
#' @param df data.frame with identifier column
#' @param id Identifier type (geneID, orf, publicName)
#' @param type Output type (report, simple)
#'
#' @return data.frame cbind with metadata
#' @export
metadataBind <- function(df, id = "geneId", type = "simple") {
  vec <- df[, id]
  df <- cbind(df, metadata(vec, id = id, type = type))
  df <- df[, unique(names(df))]
  return(df)
}


#' Feeding RNAi Library clone matching
#'
#' @param cloneId Clone identifier
#' @param lib Feeding library (orfeome, ahringer)
#' @param type Output type (simple, report)
#'
#' @return data.frame with metadata
#' @export
rnai <- function(cloneId = NULL,
                 lib = "orfeome",
                 type = "simple") {
  if (lib == "ahringer") {
    df <- ahringerMaster
  } else {
    df <- orfeomeMaster
  }
  rownames(df) <- df$cloneId

  # Subset rows
  rowNames <- cloneId
  if (!is.null(rowNames)) {
    df <- df[rowNames, ]
  }

  df <- metadataBind(df, id = "orf", type = type)

  # Subset columns
  if (type == "report") {
    colNamesReport <- c("cloneId", colNamesReport)
    df <- df[, colNamesReport]
  } else {
    colNamesSimple <- c("cloneId", colNamesSimple)
    df <- df[, colNamesSimple]
  }

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
    utils::download.file(fileUrl, filePath)
  }

  # tempfile method:
  #! temp <- tempfile(fileext = ".txt.gz")
  #! utils::download.file(fileUrl, temp)

  return(filePath)
}
