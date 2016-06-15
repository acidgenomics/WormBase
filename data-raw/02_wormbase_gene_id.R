library(R.utils)
library(readr)
library(stringr)

# geneId =======================================================================
df <- read_csv(file.path("data-raw", "wormbase", "geneIDs.txt.gz"),
               col_names = FALSE,
               na = "")
# Discard uneeded columns
df <- df[, c(2, 4, 3, 5)]
colnames(df) <- c("geneId", "orf", "publicName", "status")
rownames(df) <- df$geneId
wormbaseGeneIdRows <- rownames(df)
wormbaseGeneId <- df
rm(df)

# geneOtherIds =================================================================
file <- read_file(file.path("data-raw", "wormbase", "geneOtherIDs.txt.gz"))
# Take out dead or live status, we have this from geneIDs.txt.gz
file <- gsub("\t(Dead|Live)", "", file, perl = TRUE)
# Take the tabs out for gene list
file <- gsub("\t", ", ", file)
# Add tab back in to separate geneId for row names
file <- gsub("WBGene([0-9]+), ", "WBGene\\1\t", file, perl = TRUE)
# Warnings here mean there are no other IDs for that row
# (e.g. expected: 2 columns, actual: 1 columns)
df <- suppressWarnings(read_tsv(file, col_names = FALSE))
rownames(df) <- df[, 1]
colnames(df) <- c("geneId", "geneOtherIds")
df <- df[geneIdRows, ]
df$geneId <- NULL

wormbaseGeneId <- cbind(wormbaseGeneId, df)
save(wormbaseGeneId,
     wormbaseGeneIdRows,
     file = "data-raw/gene_id.rda")
rm(df, file)
warnings()
