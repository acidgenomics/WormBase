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
#! Duplicate rows! Need to fix here
rownames(df) <- df$geneID
df$geneID <- NULL

# Select the columns desired ===================================================
# Use publicName and molecularName from geneID.R instead, so discard here
df <- df[, c("gene.class.description",
            "concise.description",
            "provisional.description",
            "automated.description")]
# Clean up the column names
colnames(df) <- gsub(".description", "", colnames(df))
df <- df[GeneID_vec, ]
description <- df
rm(df)

warnings()
