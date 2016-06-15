library(R.utils)
library(readr)

df <- read_delim(file.path("data-raw", "wormbase", "functional_descriptions.txt.gz"),
                 delim = "\t",
                 col_names = FALSE,
                 skip = 4, # column headers not properly tabbed
                 na = c("", "none available", "not known"))

# Fix the column headers =======================================================
header <- readLines(file.path("data-raw", "wormbase", "functional_descriptions.txt.gz"), n = 4)
header <- header[4]
header <- strsplit(header, " ")
colnames(df) <- header[[1]]
rm(header)
colnames(df) <- gsub("_id", "_ID", colnames(df))
colnames(df) <- toCamelCase(colnames(df), split = "_")
# Make sure geneID contains a valid ID
df <- df[grepl("^WBGene[0-9]{8}$", df$geneID), ]
rownames(df) <- df$geneID
df$geneID <- NULL

# Select the columns desired ===================================================
# Use publicName and molecularName from geneID.R instead, so discard here
df$publicName <- NULL
df$molecularName <- NULL
# Clean up the column names
## colnames(df) <- gsub("Description$", "", colnames(df))
## df <- df[geneIDRows, ]
description <- df
rm(df)

warnings()
