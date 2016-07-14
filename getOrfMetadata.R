getOrfMetadata <- function(orfOriginal) {
  # Since there are duplicate ORFs per well, we must loop from metadataOrf
  list <- list()
  list <- lapply(seq(along = orfOriginal), function(i) {
    # Strip out isoform (included in some Ahringer clones)
    orfSearch <- gsub("\\.[a-z]{1}$", "", orfOriginal[i])
    metadataOrf[orfSearch, ]
  })
  # Converting to a data frame here will take a while
  df <- data.frame(do.call("rbind", list))
  assign("orf2GeneId", df, envir = .GlobalEnv)
}
