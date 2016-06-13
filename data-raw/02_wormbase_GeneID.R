library(readr)
library(stringr)

# GeneID =======================================================================
df <- read_csv(file.path("data-raw", "wormbase", "geneIDs.txt.gz"),
               col_names = FALSE,
               na = "")
# Discard uneeded columns
df <- df[, c(2:5)]
colnames(df) <- c("GeneID", "publicName", "ORF", "wormbaseStatus")
rownames(df) <- df$GeneID
geneIDVector <- rownames(df)
geneID <- df
rm(df)

# Other IDs ====================================================================
file <- read_file(file.path("data-raw", "wormbase", "geneOtherIDs.txt.gz"))
# Take out dead or live status, we have this from geneIDs.txt
file <- gsub("\t(Dead|Live)", "", file, perl = TRUE)
# Take the tabs out for gene list
file <- gsub("\t", ", ", file)
# Add tab back in to separate GeneID for row names
file <- gsub("WBGene([0-9]+), ", "WBGene\\1\t", file, perl = TRUE)
# Warnings here mean there are no other IDs for that row
# (e.g. expected: 2 columns, actual: 1 columns)
df <- suppressWarnings(read_tsv(file, col_names = FALSE))
rownames(df) <- df[, 1]
colnames(df) <- c("GeneID", "geneOtherIDs")
df <- df[geneIDVector, ]
df$GeneID <- NULL
geneID <- cbind(geneID, df)
rm(df, file)

devtools::use_data(geneID, geneIDVector, overwrite = TRUE)
warnings()
