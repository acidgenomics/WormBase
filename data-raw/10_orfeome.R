library(R.utils)
library(readr)
library(readxl)
load("data/metadataOrf.rda")
source("data-raw/getOrfMetadata.R")

# Set up the ORFeome data frame from the Excel file ============================
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
names(df)[names(df) == "orfIdWs112"] <- "orfOriginal"

# Subset the bad wells
df <- subset(df, !is.na(rnaiWell))
df <- subset(df, orfOriginal != "no match in WS112")
rownames(df) <- df$rnaiWell
xlsxFiltered <- df

# Set plate IDs as rownames ====================================================
df <- xlsxFiltered
col <- c("plate", "row", "col")
cloneId <- do.call(paste, c(df[col], sep = "-"))
cloneId[1]
cloneId <- gsub("^(.*)-([0-9]{1})$", "\\1-0\\2", cloneId,
                  perl = TRUE, ignore.case = FALSE) # pad zeros
cloneId[1]
cloneId <- gsub("^([0-9]{5})-([A-Z]{1})-([0-9]{2})$", "\\1@\\2\\3", cloneId,
                  perl = TRUE, ignore.case = FALSE)
cloneId[1]
df <- cbind(cloneId, df)
rownames(df) <- df$cloneId
xlsxConverted <- df
rm(xlsxFiltered)

# Get current metadata =========================================================
getOrfMetadata(as.vector(xlsxConverted$orfOriginal))

# Bind the matches back to the orfeomeValid data frame
df <- xlsxConverted[, c("cloneId", "orfOriginal")]

# Now we can bind the metadata
df <- cbind(df, orf2GeneId)
rownames(df) <- as.vector(df$cloneId)
colnames(df)

# Unmapped ORFs
unmappedOrf <- subset(df, is.na(geneId))
unmappedOrf <- unmappedOrf[, 1:2]

# Remove them from main df, we'll add back later
df <- subset(df, !is.na(geneId))

# Get the ORF merge mappings
# This should have the same number of rows as unmappedOrf
orfMergeInput <- read_excel("data-raw/rnai_libraries/orf_merge.xlsx",
                   sheet = 1, na = "NA")
rownames(orfMergeInput) <- orfMergeInput$cloneId
orfMergeInput <- orfMergeInput[rownames(unmappedOrf), ]
rownames(orfMergeInput) <- rownames(unmappedOrf)

# Get the metadata of these merged ORFs
getOrfMetadata(as.vector(orfMergeInput$mergedOrf))

# Bind back to main data frame
orfMerge <- cbind(unmappedOrf, orf2GeneId)
df <- rbind(df, orfMerge)
df <- df[rownames(xlsxConverted), ]

# Add back the complete metadata
df <- cbind(xlsxConverted, df)
# Remove duplicate columns
df <- df[, unique(colnames(df))]

# Additional information for library troubleshooting
debugNoGeneId <- df[is.na(df$geneId), ]
debugUnique <- unique(as.vector(df$orf))

orfeome <- df
devtools::use_data(orfeome, overwrite = TRUE)

warnings()
