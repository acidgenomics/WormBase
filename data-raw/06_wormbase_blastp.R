library(biomaRt)
library(plyr)
library(R.utils)
library(readr)

# Get the highest match for each peptide =======================================
input <- read_csv(file.path("data-raw", "wormbase", "best_blastp_hits.txt.gz"),
                  col_names = FALSE)
df <- input[, c(1, 4, 5)]
colnames(df) <- c("wormpepId",
                  "ensemblPeptideId",
                  "eValue")
# Filter for only ENSEMBL info
df <- df[grepl("ENSEMBL", df$ensemblPeptideId), ]
# Remove "ENSEMBL:" from column
df$ensemblPeptideId <- substr(df$ensemblPeptideId, 9, 23)
# Sort by E value to get the highest confidence BLASTP match
df <- df[order(df$wormpepId, df$eValue), ]
# Now remove duplicates, will which eliminate the lower confidence entries
df <- df[!duplicated(df$wormpepId), ]
rownames(df) <- as.vector(df$wormpepId)
blastpScores <- df
rm(df, input)

# Map peptides to WBGeneID =====================================================
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
colnames(df) <- c("wormpepId", "geneId")
wormpepId <- df

# Match E values to WBGeneID ===================================================
vec <- as.vector(wormpepId$wormpepId)
ensembl <- blastpScores[vec, c("ensemblPeptideId", "eValue")]
df <- cbind(df, ensembl)
rm(ensembl, vec)
# Subset only the top blastp with ensembl match
df <- df[order(df$geneId, df$eValue, df$wormpepId), ]
df <- df[!duplicated(df$geneId), ]
df <- df[!is.na(df$ensemblPeptideId), ]
rownames(df) <- df$geneId
# Clean up the names for binding
df$geneId <- NULL
blastpGeneId <- df
rm(df)

# biomaRt for human orthologs ==================================================
ensemblPeptideId <- as.vector(blastpGeneId$ensemblPeptideId)
mart <- useMart("ensembl", "hsapiens_gene_ensembl")
biomartOptions <- listAttributes(mart)
df <- getBM(mart = mart,
            filters = "ensembl_peptide_id",
            values = ensemblPeptideId,
            attributes = c("ensembl_peptide_id",
                           "ensembl_gene_id",
                           "external_gene_name",
                           "description"))
colnames(df)[colnames(df) == "external_gene_name"] <- "ensembl_gene_name"
colnames(df)[colnames(df) == "description"] <- "ensembl_description"
colnames(df) <- toCamelCase(colnames(df), split = "_")
rownames(df) <- df$ensemblPeptideId
df$ensemblPeptideId <- NULL
df <- df[ensemblPeptideId, ]
df <- cbind(blastpGeneId, df)

load("data-raw/gene_id.rda")
df <- df[wormbaseGeneIdRows, ]
rownames(df) <- wormbaseGeneIdRows

wormbaseBlastp <- df

rm(biomartOptions,
   blastpGeneId,
   blastpScores,
   df,
   ensemblPeptideId,
   input,
   mart,
   wormpepId)
warnings()
