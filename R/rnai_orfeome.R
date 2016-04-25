pkg <- c("readxl")
source("R/cran_packages.R")
load("rda/metadata.rda")

# Import the Excel file ========================================================
input <- read_excel("source_data/orfeome.xlsx", sheet = 2)
colnames(input) <- gsub(" ", ".", colnames(input))

# Set up the data frame converted from Excel ===================================
df <- data.frame()
df <- input[, c("ORF.ID.(WS112)",
                "Plate",
                "Row",
                "Col",
                "RNAi.well")]
names(df)[names(df) == "ORF.ID.(WS112)"] <- "ORF"

# Subset the bad wells =========================================================
df <- subset(df, !is.na(RNAi.well))
df <- subset(df, ORF != "no match in WS112")
input_subset <- df
rm(df)

# Set plate IDs as rownames ====================================================
df <- input_subset
col <- c("Plate", "Row", "Col")
ORFeomeID <- do.call(paste, c(df[col], sep = "-"))
rm(col)
ORFeomeID[1]
ORFeomeID <- gsub("^(.*)-([0-9]{1})$", "\\1-0\\2", ORFeomeID,
                  perl = TRUE, ignore.case = FALSE) # pad zeros
ORFeomeID[1]
ORFeomeID <- gsub("^([0-9]{5})-([A-Z]{1})-([0-9]{2})$", "\\1@\\2\\3", ORFeomeID,
                  perl = TRUE, ignore.case = FALSE)
ORFeomeID[1]
df <- cbind(ORFeomeID, df)
rownames(df) <- df$ORFeomeID
orfeome_valid <- df
rm(df, ORFeomeID)

# Get current metadata =========================================================
# Since there are duplicate ORFs per well, we must loop from metadata_ORF
df <- orfeome_valid
orf <- as.vector(df$ORF)
list <- list()
list <- lapply(seq(along = orf), function(i) {
  metadata_ORF[orf[i], ]
})
# Converting to a data frame here will take a while
df <- data.frame(do.call("rbind", list))
ORF_to_GeneID <- df
rm(df, list, orf)
# Bind the matches back to the valid orfeome data frame
df <- data.frame()
df <- cbind(ORF_to_GeneID, orfeome_valid)
rownames(df) <- as.vector(df$ORFeomeID)
# Remove duplicate columns
# This will only remove the first instance, here from ORF_to_GeneID
df$ORF <- NULL
df$ORFeomeID <- NULL
# Remove unnecessary plate information
df$Plate <- NULL
df$Row <- NULL
df$Col <- NULL
colnames(df)
# This will remove Plate, Row, Col
df <- df[, c("RNAi.well",
             "ORF",
             "GeneID",
             "public.name",
             "gene.other.ids")]
orfeome <- df
rm(df)

# Additional information for library troubleshooting ===========================
orfeome_unmatched <- orfeome[is.na(orfeome$GeneID), ]
orfeome_unique <- unique(as.vector(orfeome$ORF))

# Save =========================================================================
save(orfeome, file = "rda/orfeome.rda")
write.csv(orfeome, "csv/orfeome.csv")
system("gzip --force csv/orfeome.csv")
warnings()
