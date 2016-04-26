rm(list = ls(all.names = TRUE))

# Create fresh output folders ==================================================
if (file.exists("csv")) {
  unlink("csv", recursive = TRUE)
}
if (file.exists("rda")) {
  unlink("rda", recursive = TRUE)
}
dir.create("csv")
dir.create("rda")

# Source the .R code files =====================================================
# Download current files from WormBase and PANTHER
source("R/source_data.R", verbose = TRUE)

# Loop through the source files
datasets <- c("GeneID", "description", "rnai_phenotypes", "blastp",
              "orthologs", "biomart", "panther")
invisible(lapply(seq(along = datasets), function(i) {
  file <- paste0("R/", datasets[i], ".R")
  source(file, verbose = TRUE)
}))

# Load the saved .rda files for compile
invisible(lapply(seq(along = datasets), function(i) {
  file <- paste0("rda/", datasets[i], ".rda")
  load(file, .GlobalEnv)
}))

# Compile the master metadata data.frame =======================================
metadata <- data.frame()
metadata <- do.call(cbind, mget(datasets))
colnames(metadata) <- gsub("\\_", ".", colnames(metadata))
colnames(metadata) <- gsub("GeneID.", "", colnames(metadata))
write.csv(metadata,
          gzfile("csv/metadata.csv.gz"),
          row.names = FALSE)

# Save a list of available columns =============================================
colnames <- colnames(metadata)
write(colnames, "colnames.txt", sep = "\n")

# Simple version ===============================================================
metadata_simple <- metadata[, c("GeneID",
                                "ORF",
                                "public.name",
                                "gene.other.ids")]
write.csv(metadata_simple,
          gzfile("csv/metadata_simple.csv.gz"),
          row.names = FALSE)
# Rownames by ORF instead of GeneID (Wormbase ID) ==============================
metadata_ORF <- metadata_simple
metadata_ORF <- subset(metadata_ORF, !is.na(metadata_ORF$ORF))
metadata_ORF <- subset(metadata_ORF, !duplicated(metadata_ORF$ORF))
rownames(metadata_ORF) <- metadata_ORF$ORF
write.csv(metadata_ORF,
          gzfile("csv/metadata_ORF.csv.gz"),
          row.names = FALSE)
save(metadata, metadata_ORF, metadata_simple, file = "rda/metadata.rda")

# Create CSV subsets ===========================================================
invisible(lapply(seq(along = datasets), function(i) {
  df <- mget(datasets[i], envir = .GlobalEnv)[[1]]
  file <- paste0("csv/", datasets[i], ".csv")
  gzfile <- paste0(file, ".gz")
  write.csv(df, file = gzfile(gzfile))
}))

# Update RNAi library metadata =================================================
# Be sure to run last!
# Requires compiled metadata.rda to be saved prior
#! source("R/rnai_ahringer.R", verbose = TRUE)
#! source("R/rnai_cherrypick.R", verbose = TRUE)
source("R/rnai_orfeome.R", verbose = TRUE)

warnings()
