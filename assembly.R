#! Ahringer and cherrypick update needed

source("http://bioconductor.org/biocLite.R")
biocLite()
biocLite(c("biomaRt", "plyr", "RCurl", "readr", "stringr"))

# https://github.com/hadley/readxl
# readxl is needed to open RNAi library spreadsheets
install.packages("readxl")

# Start assembly!
rm(list = ls(all.names = TRUE))
if (!file.exists("csv")) { dir.create("csv") }
if (!file.exists("rda")) { dir.create("rda") }

# Download current files from WormBase and PANTHER -----------------------------
source("sources.R", verbose = TRUE)

# Build the datasets -----------------------------------------------------------
datasets <- c("GeneID", "description", "rnai_phenotypes", "blastp",
              "orthologs", "biomart", "panther")

# Source the .R code files -----------------------------------------------------
lapply(seq(along = datasets), function(i) {
  file <- paste(c(datasets[i], ".R"), collapse = "")
  source(file, verbose = TRUE)
})

# Load the saved .rda files for compile ----------------------------------------
lapply(seq(along = datasets), function(i) {
  file <- paste(c("rda/",datasets[i], ".rda"), collapse = "")
  load(file, .GlobalEnv)
})

# Compile the master metadata data.frame ---------------------------------------
metadata <- data.frame()
metadata <- do.call(cbind, mget(datasets))
colnames(metadata) <- gsub("GeneID.", "", colnames(metadata))
write.csv(metadata, "csv/metadata.csv", row.names = FALSE)

# Save a list of available columns ---------------------------------------------
colnames <- colnames(metadata)
colnames
write(colnames, "colnames.txt", sep = "\n")

# Simple version ---------------------------------------------------------------
metadata_simple <- metadata[, c("GeneID", "ORF", "public.name", "gene.other.ids")]
write.csv(metadata_simple, "csv/metadata_simple.csv", row.names = FALSE)

# Rownames by ORF instead of GeneID (Wormbase ID) ------------------------------
metadata_ORF <- metadata_simple
metadata_ORF <- subset(metadata_ORF, !is.na(metadata_ORF$ORF))
metadata_ORF <- metadata_ORF[!duplicated(metadata_ORF$ORF), ]
rownames(metadata_ORF) <- metadata_ORF$ORF
write.csv(metadata_ORF, "csv/metadata_ORF.csv", row.names = FALSE)

save(metadata, metadata_ORF, metadata_simple, file = "rda/metadata.rda")

# Create CSV subsets -----------------------------------------------------------
lapply(seq(along = datasets), function(i) {
  df <- mget(datasets.gsub[i], envir = .GlobalEnv)[[1]]
  file <- paste(c("csv/", datasets[i], ".csv"), collapse = "")
  write.csv(df, file)
})

# Update RNAi library metadata -------------------------------------------------
# Be sure to run last!
# Requires compiled metadata.rda to be saved prior
#! source("ahringer.R", verbose = TRUE)
#! source("cherrypick.R", verbose = TRUE)
source("orfeome.R", verbose = TRUE)

# gzip CSV files to save disk space --------------------------------------------
system("gzip --force csv/*.csv")
