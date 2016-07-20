load("data/geneIds.rda")

load("data/ahringer.rda")
ahringerMaster <- ahringer$converted

load("data/metadata.rda")
metadataMaster <- metadata

load("data/orfeome.rda")
orfeomeMaster <- orfeome$converted

rm(ahringer, metadata, orfeome)

devtools::use_data(
  ahringerMaster,
  geneIds,
  metadataMaster,
  orfeomeMaster,
  internal = TRUE,
  overwrite = TRUE
  )
