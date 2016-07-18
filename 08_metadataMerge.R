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

# Fix any column name issues
names(df)[names(df) == "ensemblGoId"] <- "ensemblGeneOntologyId"
names(df)[names(df) == "ensemblInterpro"] <- "ensemblInterproId"
names(df)[names(df) == "ensemblName1006"] <- "ensemblGeneOntologyName"
names(df)[names(df) == "ensemblEntrezgene"] <- "ensemblEntrezGeneId"
names(df)[names(df) == "rnaiPhenotypes"] <- "wormbaseRnaiPhenotypes"

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
