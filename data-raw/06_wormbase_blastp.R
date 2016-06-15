library(biomaRt)
library(plyr)
library(R.utils)
library(readr)

# Get the highest match for each peptide =======================================
input <- read_csv(file.path("data-raw", "wormbase", "best_blastp_hits.txt.gz"), col_names = FALSE)
df <- input[, c(1, 4, 5)]
colnames(df) <- c("wormbasePeptideID", "ensemblPeptideID", "EValue")
# Filter for only ENSEMBL info
df <- df[grepl("ENSEMBL", df$ensemblPeptideID), ]
# Remove "ENSEMBL:" from column
df$ensemblPeptideID <- substr(df$ensemblPeptideID, 9, 23)
# Sort by E value to get the highest confidence BLASTP match
df <- df[order(df$wormbasePeptideID, df$EValue), ]
# Now remove duplicates, will which eliminate the lower confidence entries
df <- df[!duplicated(df$wormbasePeptideID), ]
rownames(df) <- as.vector(df$wormbasePeptideID)
blastpScores <- df
rm(df, input)

# Map peptides to WormBase GeneID ==============================================
input <- readLines(file.path("data-raw", "wormbase", "wormpep.txt.gz"))
input <- strsplit(input, "\n")
wormpep <- lapply(input, function(x) {
  x <- gsub("^.*\t(CE[0-9]+\tWBGene[0-9]+).*$", "\\1", x, perl = T)
  y <- strsplit(x, "\t")
  x <- y[[1]]
})
head(wormpep)
df <- data.frame(do.call("rbind", wormpep))
rm(wormpep)
colnames(df) <- c("wormbasePeptideID", "geneID")
wormbasePeptideID <- df

# Pull ensembl IDs and p values based on wormbase.peptide.id ===================
vec <- as.vector(wormbasePeptideID$wormbasePeptideID)
ensembl <- blastpScores[vec, c("ensemblPeptideID", "EValue")]
df <- cbind(df, ensembl)
rm(ensembl, vec)

# Subset only the top blastp with ensembl match ================================
df <- df[order(df$geneID, df$EValue, df$wormbasePeptideID), ]
df <- df[!duplicated(df$geneID), ]
df <- df[!is.na(df$ensembl), ]
rownames(df) <- df$geneID
# clean up the names for binding
df$geneID <- NULL
blastpGeneID <- df
rm(df)

# biomaRt for human orthologs ==================================================
ensemblPeptideID <- as.vector(blastpGeneID$ensemblPeptideID)
mart <- useMart("ensembl", "hsapiens_gene_ensembl")
biomartOptions <- listAttributes(mart)
df <- getBM(mart = mart,
            filters = "ensembl_peptide_id",
            values = ensemblPeptideID,
            attributes = c("ensembl_peptide_id",
                           "ensembl_gene_id",
                           "external_gene_name",
                           "description"))
## colnames(df) <- gsub("_", ".", colnames(df))
# Convert to camelCase
colnames(df) <- gsub("_id", "_ID", colnames(df))
colnames(df) <- toCamelCase(colnames(df), split = "_")
rownames(df) <- df$ensemblPeptideID
df$ensemblPeptideID <- NULL
df <- df[ensemblPeptideID, ]
df <- cbind(blastpGeneID, df)
# Set rows to metadata df
load("data/geneIDRows.rda")
blastp <- df[geneIDRows, ]
rownames(blastp) <- geneIDRows
rm(biomartOptions,
   blastpGeneID,
   blastpScores,
   df,
   ensemblPeptideID,
   input,
   mart,
   wormbasePeptideID)
warnings()
