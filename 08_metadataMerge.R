library(seqcloudR)

datasets <- c("wormbaseGeneId",
              "wormbaseDescription",
              "wormbaseRnaiPhenotypes",
              "wormbaseOrthologs",
              "wormbaseBlastp",
              "ensembl",
              "panther")
dataFiles <- paste0("data/", datasets, ".rda")
lapply(dataFiles, load, .GlobalEnv)
df <- do.call(cbind, mget(datasets))

# Modify wormbase prefix
names(df) <- gsub("^wormbase(Description|GeneId)", "wormbase", names(df))

# Take out prefix for commonly used identifiers
names(df) <- gsub("^wormbase\\.(geneId|publicName|orf)", "\\1", names(df))

# camelCase
names(df) <- camel(names(df))

# Clean cruft from cells
df <- cleanCells(df)
metadata <- df

metadataSimple <- metadata[, c("geneId",
                               "orf",
                               "publicName",
                               "wormbaseGeneOtherIds")]

# Rownames by ORF instead of WBGeneID
metadataOrf <- metadataSimple
metadataOrf <- subset(metadataOrf, !is.na(metadataOrf$orf))
metadataOrf <- subset(metadataOrf, !duplicated(metadataOrf$orf))
rownames(metadataOrf) <- metadataOrf$orf

# Additional detail useful for reports
metadataReport <- metadata[, c(
  "geneId",
  "orf",
  "publicName",
  "wormbaseGeneOtherIds",
  "wormbaseGeneClassDescription",
  "wormbaseConciseDescription",
  "wormbaseBlastpEnsemblGeneName",
  "wormbaseBlastpEnsemblDescription",
  "wormbaseStatus",
  "ensemblGeneBiotype",
  "pantherFamilyName",
  "pantherSubfamilyName"
)]

devtools::use_data(metadata,
                   metadataOrf,
                   metadataReport,
                   metadataSimple,
                   overwrite = TRUE)

# Move source .rda files to data-raw
dataFilesRename <- gsub("data/", "data-raw/", dataFiles)
dataFilesRename
file.rename(dataFiles, dataFilesRename)
