pkg <- c("readr", "stringr")
source("R/bioc_packages.R")

# GeneID =======================================================================
df <- read_csv("source_data/wormbase/geneIDs.txt.gz",
               col_names = FALSE,
               na = "")
# Discard uneeded columns
df <- df[, c(2:5)]
colnames(df) <- c("GeneID", "public.name", "ORF", "wormbase.status")
rownames(df) <- df$GeneID
GeneID_vec <- rownames(df)
GeneID <- df
rm(df)

# Other IDs ====================================================================
file <- read_file("source_data/wormbase/geneOtherIDs.txt.gz")
# Take out dead or live status, we have this from geneIDs.txt
file <- gsub("\t(Dead|Live)", "", file, perl = TRUE)
# Take the tabs out for gene list
file <- gsub("\t", ", ", file)
# Add tab back in to separate GeneID for row names
file <- gsub("WBGene([0-9]+), ", "WBGene\\1\t", file, perl = TRUE)
# Warnings here mean there are no other IDs for that row
# e.g. expected: 2 columns, actual: 1 columns
df <- read_tsv(file, col_names = FALSE)
rownames(df) <- df[, 1]
colnames(df) <- c("GeneID", "gene.other.ids")
df <- df[GeneID_vec, ]
df$GeneID <- NULL
GeneID <- cbind(GeneID, df)
rm(df, file)
save(GeneID, GeneID_vec, file = "rda/GeneID.rda")
warnings()
