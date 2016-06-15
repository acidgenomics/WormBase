datasets <- c("wormbaseGeneId",
              "wormbaseDescription",
              "wormbaseRnaiPhenotypes",
              "wormbaseOrthologs",
              "wormbaseBlastp",
              "ensembl",
              "panther")
df <- do.call(cbind, mget(datasets))
names(df)

# Add wormbase prefix
names(df)[names(df) == "rnaiPhenotypes"] <- "wormbaseRnaiPhenotypes"
# Modify wormbase prefix
names(df) <- gsub("^wormbase(Description|GeneId)", "wormbase", names(df))
# Take out prefix for commonly used identifiers
names(df) <- gsub("^wormbase\\.(geneId|publicName|orf)", "\\1", names(df))
# camelCase
names(df) <- gsub("\\.([[:lower:]])", "\\U\\1", names(df), perl = TRUE)

# Set any blank cells to NA
metadata <-
  data.frame(apply(metadata, 2, function(x)
    gsub("^$|^ $", NA, x)))

# Fix leading and trailing commas
df <-
  data.frame(apply(df, 2, function(x)
    gsub("^(,|\\s//)\\s(.*)", "\\2", x, perl = TRUE)))
df <-
  data.frame(apply(df, 2, function(x)
    gsub("(.*)(,|\\s//)\\s$", "\\1", x, perl = TRUE)))

lapply(df, class)
names(df)

metadata <- df
rm(df)

metadataSimple <- metadata[, c("geneId",
                               "orf",
                               "publicName")]

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
warnings()
