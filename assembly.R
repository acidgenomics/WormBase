source("http://bioconductor.org/biocLite.R")
biocLite()
biocLite("BiocUpgrade")
biocLite(c("biomaRt", "plyr", "RCurl", "readr", "stringr"))

# openxlsx is needed to load the ORFeome RNAi information
install.packages("openxlsx", dependencies = T)

# Start assembly!
rm(list = ls(all.names = T))
if (!file.exists("csv")) { dir.create("csv") }
if (!file.exists("rda")) { dir.create("rda") }

# Download current files from WormBase and PANTHER -----------------------------
source("sources.R")

# Build the datasets -----------------------------------------------------------
datasets <- c("GeneID", "description", "rnai_phenotypes", "blastp",
              "orthologs", "biomart", "panther")
datasets.gsub <- gsub("_", ".", datasets)

# Source the .R code files -----------------------------------------------------
lapply(seq(along = datasets), function(i) {
  file <- paste(c(datasets[i], ".R"), collapse = "")
  source(file, verbose = T)
})

# Load the saved .rda files for compile ----------------------------------------
lapply(seq(along = datasets), function(i) {
  file <- paste(c("rda/",datasets[i], ".rda"), collapse = "")
  load(file, .GlobalEnv)
})

# Compile the master metadata data.frame ---------------------------------------
df <- data.frame()
df <- do.call(cbind, mget(datasets.gsub))
colnames(df) <- gsub("GeneID.", "", colnames(df))
metadata <- df
write.csv(metadata, "csv/metadata.csv", row.names = F)

# Save a list of available columns ---------------------------------------------
colnames <- colnames(metadata)
colnames
write(colnames, "colnames.txt", sep = "\n")

# Simple version ---------------------------------------------------------------
metadata.simple <- df[, c("GeneID", "ORF", "public.name")]
write.csv(metadata.simple, "csv/metadata_simple.csv", row.names = F)

# Rownames by ORF instead of GeneID (Wormbase ID) ------------------------------
metadata.ORF <- df[, c("ORF", "GeneID", "public.name")]
metadata.ORF <- metadata.ORF[!duplicated(metadata.ORF$ORF), ]
metadata.ORF <- subset(metadata.ORF, !is.na(metadata.ORF$ORF))
rownames(metadata.ORF) <- metadata.ORF$ORF
write.csv(metadata.ORF, "csv/metadata_ORF.csv", row.names = F)

save(metadata, metadata.ORF, metadata.simple, file = "rda/metadata.rda")

# Create CSV subsets -----------------------------------------------------------
lapply(seq(along = datasets), function(i) {
  df <- mget(datasets.gsub[i], envir = .GlobalEnv)[[1]]
  file <- paste(c("csv/", datasets[i], ".csv"), collapse = "")
  write.csv(df, file)
})

# Update ORFome RNAi metadata for screening info -------------------------------
# Be sure to run last! CPU intensive and requires compiled metadata.rda
source("orfeome.R", verbose = T)

# gzip CSV files to save disk space --------------------------------------------
system("gzip --force csv/*.csv")
