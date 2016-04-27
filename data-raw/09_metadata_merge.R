# Load the datasets
datasets <- c("GeneID",
              "description",
              "rnai_phenotypes",
              "orthologs",
              "blastp",
              "biomart",
              "panther")
invisible(lapply(seq(along = datasets), function(i) {
  file <- file.path("data", paste0(datasets[i], ".rda"))
  load(file)
}))

# Compile the master metadata data.frame
metadata <- data.frame()
metadata <- do.call(cbind, mget(datasets))
colnames(metadata) <- gsub("\\_", ".", colnames(metadata))
colnames(metadata) <- gsub("GeneID.", "", colnames(metadata))

# Simple version
metadata_simple <- metadata[, c("GeneID",
                                "ORF",
                                "public.name",
                                "gene.other.ids")]

# Rownames by ORF instead of GeneID (Wormbase ID)
metadata_ORF <- metadata_simple
metadata_ORF <- subset(metadata_ORF, !is.na(metadata_ORF$ORF))
metadata_ORF <- subset(metadata_ORF, !duplicated(metadata_ORF$ORF))
rownames(metadata_ORF) <- metadata_ORF$ORF

devtools::use_data(metadata, metadata_ORF, metadata_simple, overwrite = TRUE)
warnings()
