library(R.utils)
library(readr)
library(readxl)
load("data/metadataOrf.rda")

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

# Set up the data frame from Excel file ========================================
xlsx <- read_excel("data-raw/rnai_libraries/orfeome.xlsx", sheet = 2)
# Strip parenthesis from column title
colnames(xlsx) <- gsub("(\\(|\\))", "", colnames(xlsx))
colnames(xlsx) <- tolower(colnames(xlsx))
colnames(xlsx) <- toCamelCase(colnames(xlsx))

# Select the desired columns and rename
df <- data.frame()
df <- xlsx[, c("orfIdWs112",
               "plate",
               "row",
               "col",
               "rnaiWell")]
names(df)[names(df) == "orfIdWs112"] <- "orf"

# Subset the bad wells
df <- subset(df, !is.na(rnaiWell))
df <- subset(df, orf != "no match in WS112")
rownames(df) <- df$rnaiWell
xlsxFiltered <- df

# Set plate IDs as rownames ====================================================
df <- xlsxFiltered
col <- c("plate", "row", "col")
orfeomeId <- do.call(paste, c(df[col], sep = "-"))
orfeomeId[1]
orfeomeId <- gsub("^(.*)-([0-9]{1})$", "\\1-0\\2", orfeomeId,
                  perl = TRUE, ignore.case = FALSE) # pad zeros
orfeomeId[1]
orfeomeId <- gsub("^([0-9]{5})-([A-Z]{1})-([0-9]{2})$", "\\1@\\2\\3", orfeomeId,
                  perl = TRUE, ignore.case = FALSE)
orfeomeId[1]
df <- cbind(orfeomeId, df)
rownames(df) <- df$orfeomeId
xlsxConverted <- df
rm(xlsxFiltered)

# Get current metadata =========================================================
getOrfMetadata(as.vector(xlsxConverted$orf))

# Bind the matches back to the orfeomeValid data frame
df <- xlsxConverted[, c("orfeomeId", "orf")]

# Keep original ORF information from xlsx file
names(df)[names(df) == "orf"] <- "orfOriginal"

# Now we can bind the metadata
df <- cbind(df, orf2GeneId)
rownames(df) <- as.vector(df$orfeomeId)
colnames(df)

# Unmapped ORFs
unmappedOrf <- subset(df, is.na(geneId))
unmappedOrf <- unmappedOrf[, 1:2]

# Remove them from main df, we'll add back later
df <- subset(df, !is.na(geneId))

# Get the ORF merge mappings
# This should have the same number of rows as unmappedOrf
orfMergeInput <- read_excel("data-raw/rnai_libraries/orfeome_merge.xlsx",
                   sheet = 1, na = "NA")
rownames(orfMergeInput) <- orfMergeInput$orfeomeId
orfMergeInput <- orfMergeInput[rownames(unmappedOrf), ]
rownames(orfMergeInput) <- rownames(unmappedOrf)

# Get the metadata of these merged ORFs
getOrfMetadata(as.vector(orfMergeInput$mergedOrf))

# Bind back to main data frame
orfMerge <- cbind(unmappedOrf, orf2GeneId)
df <- rbind(df, orfMerge)
df <- df[rownames(xlsxConverted), ]

# Additional information for library troubleshooting
debugNoGeneId <- df[is.na(df$geneId), ]
debugUnique <- unique(as.vector(df$orf))

orfeome <- df
devtools::use_data(orfeome, overwrite = TRUE)

warnings()
