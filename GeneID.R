pkg <- c("readr", "stringr")
lapply(pkg, require, character.only = TRUE)
# GeneID =======================================================================
df <- read.csv("sources/geneIDs.txt.gz", header = FALSE, na.strings = "")
df <- df[, c(2:5)] # discard uneeded columns
colnames(df) <- c("GeneID", "public.name", "ORF", "wormbase.status")
rownames(df) <- df$GeneID
GeneID_vec <- rownames(df)
GeneID <- df
rm(df)
# Other IDs ====================================================================
file <- read_file("sources/geneOtherIDs.txt.gz")
# Take out dead or live status, we have this from geneIDs.txt
file <- gsub("\t(Dead|Live)", "", file, perl = TRUE)
# Take the tabs out for gene list
file <- gsub("\t", ", ", file)
# Add tab back in to separate GeneID for row names
file <- gsub("WBGene([0-9]+), ", "WBGene\\1\t", file, perl = TRUE)
# Parsing failures here means there are no other IDs for that row
df <- read_tsv(file, col_names = FALSE)
rownames(df) <- df[, 1]
colnames(df) <- c("GeneID", "gene.other.ids")
df <- df[GeneID_vec, ]
df$GeneID <- NULL
GeneID <- cbind(GeneID, df)
rm(df, file)
save(GeneID, GeneID_vec, file = "rda/GeneID.rda")
warnings()
