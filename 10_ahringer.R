library(R.utils)
library(readr)
library(readxl)
load("data/metadataOrf.rda")
source("data-raw/getOrfMetadata.R")

# Source the Excel file
# http://www.us.lifesciences.sourcebioscience.com/clone-products/non-mammalian/c-elegans/c-elegans-rnai-library/
ahringerSource <- tempfile(fileext = ".xlsx")
download.file("http://www.us.lifesciences.sourcebioscience.com/media/381254/C.%20elegans%20Database%202012.xlsx", ahringerSource)

# Set up the ahringer data frame from the Excel file ============================
chromosomes <- c("I", "II", "III", "IV", "V", "X")
for (i in 1:length(chromosomes)) {
  sheet <- i + 1 # First sheet contains notes
  df <- suppressWarnings(read_excel(ahringerSource, sheet = sheet))
  colnames(df) <- toCamelCase(colnames(df))

  # Drop wells from NA plates
  df <- subset(df, !is.na(plate))

  col <- c("chrom", "plate", "well")
  cloneId <- do.call(paste, c(df[col], sep = "-"))
  cloneId[1]
  cloneId <- gsub("^(.+)-(.+)-", "\\1-\\2@\\3", cloneId, perl = TRUE)
  cloneId[1]
  df <- cbind(cloneId, df)
  rownames(df) <- df$cloneId
  name <- paste0("chr", chromosomes[i])
  assign(name, df)
}
rm(df, i)
list <- list(chrI, chrII, chrIII, chrIV, chrV, chrX)
xlsx <- data.frame(do.call("rbind", list))

# Set up working data frame and rename ORF
df <- xlsx
names(df)[names(df) == "genePairsName"] <- "orfOriginal"
xlsxConverted <- df

# Get current metadata =========================================================
getOrfMetadata(as.vector(xlsxConverted$orfOriginal))

# Bind the matches back to the xlsxConverted data frame
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

ahringer <- df
devtools::use_data(ahringer, overwrite = TRUE)

warnings()
