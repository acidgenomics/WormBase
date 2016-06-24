getOrfMetadata <- function(orf) {
  # Since there are duplicate ORFs per well, we must loop from metadata_ORF
  list <- list()
  list <- lapply(seq(along = orf), function(i) {
    metadataOrf[orf[i], ]
  })
  # Converting to a data frame here will take a while
  df <- data.frame(do.call("rbind", list))
  assign("orf2GeneId", df, envir = .GlobalEnv)
}
