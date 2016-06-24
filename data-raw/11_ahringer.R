library(R.utils)
library(readr)
library(readxl)
load("data/metadataOrf.rda")
source("data-raw/getOrfMetadata.R")

# Set up the ahringer data frame from the Excel file ============================
chromosomes <- c("I", "II", "III", "IV", "V", "X")
for (i in 1:length(chromosomes)) {
  sheet <- i + 1 # First sheet contains notes
  df <- suppressWarnings(read_excel("data-raw/rnai_libraries/ahringer.xlsx",
                                      sheet = sheet))
  colnames(df) <- toCamelCase(colnames(df))
  # Remove any dupicates (e.g. ChrV has one)
  df <- df[!duplicated(df$sourceBioscienceLocation), ]
  rownames(df) <- df$sourceBioscienceLocation
  name <- paste0("chr", chromosomes[i])
  assign(name, df)
}
rm(df, i)
list <- list(chrI, chrII, chrIII, chrIV, chrV, chrX)
xlsx <- data.frame(do.call("rbind", list))


# Set up working data frame and rename ORF
df <- xlsx
names(df)[names(df) == "genePairsName"] <- "orf"
names(df)[names(df) == "sourceBioscienceLocation"] <- "ahringerId"
xlsxConverted <- df

# Get current metadata =========================================================
getOrfMetadata(as.vector(xlsxConverted$orf))

# Bind the matches back to the xlsxConverted data frame
df <- xlsxConverted[, c("ahringerId", "orf")]

# Keep original ORF information from xlsx file
names(df)[names(df) == "orf"] <- "orfOriginal"

# Now we can bind the metadata
df <- cbind(df, orf2GeneId)
rownames(df) <- as.vector(df$ahringerId)
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
rownames(orfMergeInput) <- orfMergeInput$ahringerId
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

ahringer <- df
devtools::use_data(ahringer, overwrite = TRUE)

warnings()
