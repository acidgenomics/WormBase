rm(list = ls(all.names = TRUE))

# Set up the output folders ====================================================
if (!file.exists("csv")) {
  unlink("csv", recursive = TRUE)
}
if (!file.exists("rda")) {
  unlink("rda", recursive = TRUE)
}
dir.create("csv")
dir.create("rda")

# Source the .R code files =====================================================
# Download current files from WormBase and PANTHER
source("R/source_data.R", verbose = TRUE)
# Loop through the source files
datasets <- c("geneid", "description", "rnai_phenotypes", "blastp",
              "orthologs", "biomart", "panther")
lapply(seq(along = datasets), function(i) {
  file <- paste0("R/", datasets[i], ".R")
  source(file, verbose = TRUE)
})
# Load the saved .rda files for compile
lapply(seq(along = datasets), function(i) {
  file <- paste0("rda/", datasets[i], ".rda")
  load(file, .GlobalEnv)
})

# Compile the master metadata data.frame =======================================
metadata <- data.frame()
metadata <- do.call(cbind, mget(datasets))
colnames(metadata) <- gsub("GeneID.", "", colnames(metadata))
write.csv(metadata, "csv/metadata.csv", row.names = FALSE)

# Save a list of available columns =============================================
colnames <- colnames(metadata)
colnames
write(colnames, "colnames.txt", sep = "\n")

# Simple version ===============================================================
metadata_simple <- metadata[, c("GeneID",
                                "ORF",
                                "public.name",
                                "gene.other.ids")]
write.csv(metadata_simple, "csv/metadata_simple.csv", row.names = FALSE)
# Rownames by ORF instead of GeneID (Wormbase ID) ==============================
metadata_ORF <- metadata_simple
metadata_ORF <- subset(metadata_ORF, !is.na(metadata_ORF$ORF))
metadata_ORF <- metadata_ORF[!duplicated(metadata_ORF$ORF), ]
rownames(metadata_ORF) <- metadata_ORF$ORF
write.csv(metadata_ORF, "csv/metadata_ORF.csv", row.names = FALSE)
save(metadata, metadata_ORF, metadata_simple, file = "rda/metadata.rda")

# Create CSV subsets ===========================================================
lapply(seq(along = datasets), function(i) {
  df <- mget(datasets[i], envir = .GlobalEnv)[[1]]
  file <- paste(c("csv/", datasets[i], ".csv"), collapse = "")
  write.csv(df, file)
})
system("gzip --force csv/*.csv")

# Update RNAi library metadata =================================================
# Be sure to run last!
# Requires compiled metadata.rda to be saved prior
#! source("R/rnai_ahringer.R", verbose = TRUE)
#! source("R/rnai_cherrypick.R", verbose = TRUE)
source("R/rnai_orfeome.R", verbose = TRUE)
warnings()
