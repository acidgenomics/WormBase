rm(list = ls(all.names = T))
pkg <- c("biomaRt", "plyr")
lapply(pkg, require, character.only = T)
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
blastp.scores <- df
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
wormbase.peptide.id <- df

# Pull ensembl IDs and p values based on wormbase.peptide.id -------------------
vec <- as.vector(wormbase.peptide.id$wormbase.peptide.id)
ensembl <- blastp.scores[vec, c("ensembl.peptide.id", "e.val")]
df <- cbind(df, ensembl)
rm(ensembl)

# Subset only the top blastp with ensembl match --------------------------------
df <- df[order(df$GeneID, df$e.val, df$wormbase.peptide.id), ]
df <- df[!duplicated(df$GeneID), ]
df <- df[!is.na(df$ensembl), ]
rownames(df) <- df$GeneID
# clean up the names for binding
df$GeneID <- NULL
blastp.GeneID <- df
rm(df)

# biomaRt for human orthologs --------------------------------------------------
ensembl.peptide.id <- as.vector(blastp.GeneID$ensembl.peptide.id)
mart <- useMart("ensembl", "hsapiens_gene_ensembl")
biomart.options <- listAttributes(mart)
df <- getBM(mart = mart,
            filters = "ensembl_peptide_id",
            values = ensembl.peptide.id,
            attributes = c("ensembl_peptide_id",
                           "ensembl_gene_id",
                           "external_gene_name",
                           "description"))
rownames(df) <- df$ensembl_peptide_id
df$ensembl_peptide_id <- NULL
df <- df[ensembl.peptide.id, ]
df <- cbind(blastp.GeneID, df)
colnames(df) <- gsub("_", ".", colnames(df))
# Set rows to metadata df
blastp <- df[GeneID.vec, ]
rownames(blastp) <- GeneID.vec
rm(df)

save(blastp, file = "rda/blastp.rda")
