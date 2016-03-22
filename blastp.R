pkg <- c("biomaRt", "plyr")
lapply(pkg, require, character.only = TRUE)
load("rda/GeneID.rda")

# Get the highest match for each peptide ---------------------------------------
input <- read.csv("sources/best_blastp_hits.txt.gz", header = FALSE)
df <- input[, c(1,4,5)]
colnames(df) <- c("wormbase.peptide.id", "ensembl.peptide.id", "e.val")
# Filter for only ENSEMBL info
grep <- grepl("ENSEMBL", df$ensembl.peptide.id)
df <- df[grep, ]
rm(grep)
# Remove "ENSEMBL:" from column
df$ensembl.peptide.id <- substr(df$ensembl.peptide.id, 9, 23)
# Now sort by E value
df <- df[order(df$wormbase.peptide.id, df$e.val), ]
df <- df[!duplicated(df$wormbase.peptide.id), ]
rownames(df) <- as.vector(df$wormbase.peptide.id)
blastp_scores <- df
rm(df, input)

# Map peptides to WormBase GeneID ----------------------------------------------
input <- readLines("sources/wormpep.txt.gz")
input <- strsplit(input, "\n")
wormpep <- lapply(input, function(x) {
  x <- gsub("^.*\t(CE[0-9]+\tWBGene[0-9]+).*$", "\\1", x, perl = T)
  y <- strsplit(x, "\t")
  x <- y[[1]]
})
head(wormpep)
df <- data.frame(do.call("rbind", wormpep))
rm(wormpep)
colnames(df) <- c("wormbase.peptide.id", "GeneID")
wormbase_peptide_id <- df

# Pull ensembl IDs and p values based on wormbase.peptide.id -------------------
vec <- as.vector(wormbase_peptide_id$wormbase.peptide.id)
ensembl <- blastp_scores[vec, c("ensembl.peptide.id", "e.val")]
df <- cbind(df, ensembl)
rm(ensembl)

# Subset only the top blastp with ensembl match --------------------------------
df <- df[order(df$GeneID, df$e.val, df$wormbase.peptide.id), ]
df <- df[!duplicated(df$GeneID), ]
df <- df[!is.na(df$ensembl), ]
rownames(df) <- df$GeneID
# clean up the names for binding
df$GeneID <- NULL
blastp_GeneID <- df
rm(df)

# biomaRt for human orthologs --------------------------------------------------
ensembl_peptide_id <- as.vector(blastp_GeneID$ensembl.peptide.id)
mart <- useMart("ensembl", "hsapiens_gene_ensembl")
biomart_options <- listAttributes(mart)
df <- getBM(mart = mart,
            filters = "ensembl_peptide_id",
            values = ensembl_peptide_id,
            attributes = c("ensembl_peptide_id",
                           "ensembl_gene_id",
                           "external_gene_name",
                           "description"))
colnames(df) <- gsub("_", ".", colnames(df))
rownames(df) <- df$ensembl.peptide.id
df$ensembl.peptide.id <- NULL
df <- df[ensembl_peptide_id, ]
df <- cbind(blastp_GeneID, df)
# Set rows to metadata df
blastp <- df[GeneID_vec, ]
rownames(blastp) <- GeneID_vec
rm(df)

save(blastp, file = "rda/blastp.rda")
warnings()
