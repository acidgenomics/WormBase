pkg <- c("readxl")
lapply(pkg, require, character.only = TRUE)
load("rda/metadata.rda")

# Import the Excel file ========================================================
input <- read_excel("sources/orfeome.xlsx", sheet = 2)
colnames(input) <- gsub(" ", ".", colnames(input))

# Set up the data frame converted from Excel ===================================
x <- data.frame()
x <- input[, c("ORF.ID.(WS112)",
               "Plate",
               "Row",
               "Col",
               "RNAi.well",
               "Nonv",
               "Vpep",
               "Simmer")]
names(x)[names(x) == "ORF.ID.(WS112)"] <- "ORF"
# Subset the bad wells =========================================================
x <- subset(x, !is.na(RNAi.well))
x <- subset(x, ORF != "no match in WS112")
input_subset <- x
rm(x)
# Set plate IDs as rownames ====================================================
x <- input_subset
col <- c("Plate", "Row", "Col")
ORFeomeID <- do.call(paste, c(x[col], sep = "-"))
rm(col)
ORFeomeID[1]
ORFeomeID <- gsub("^(.*)-([0-9]{1})$", "\\1-0\\2", ORFeomeID,
                  perl = TRUE, ignore.case = FALSE) # pad zeros
ORFeomeID[1]
ORFeomeID <- gsub("^([0-9]{5})-([A-Z]{1})-([0-9]{2})$", "\\1@\\2\\3", ORFeomeID,
                  perl = TRUE, ignore.case = FALSE)
ORFeomeID[1]
x <- cbind(ORFeomeID, x)
rownames(x) <- x$ORFeomeID
orfeome_valid <- x
rm(x, ORFeomeID)
# Get current metadata =========================================================
# Since there are duplicate ORFs per well, we must loop from metadata_ORF
x <- orfeome_valid
orf <- as.vector(x$ORF)
list <- list()
list <- lapply(seq(along = orf), function(i) {
  metadata_ORF[orf[i], ]
})
# Converting to a data frame here will take a while
x <- data.frame(do.call("rbind", list))
ORF_to_GeneID <- x
rm(x, list, orf)
# Bind the matches back to the valid orfeome data frame ------------------------
x <- data.frame()
x <- cbind(ORF_to_GeneID, orfeome_valid)
rownames(x) <- as.vector(x$ORFeomeID)
# Remove duplicate columns -----------------------------------------------------
# This will only remove the first instance, here from ORF_to_GeneID
x$ORF <- NULL
x$ORFeomeID <- NULL
# Remove unnecessary plate information
x$Plate <- NULL
x$Row <- NULL
x$Col <- NULL
colnames(x)
# This will remove Plate, Row, Col
x <- x[, c("RNAi.well",
           "ORF",
           "GeneID",
           "public.name",
           "gene.other.ids",
           "Nonv",
           "Vpep",
           "Simmer")]
orfeome <- x
orfeome_simple <- x[, c("ORF", "GeneID", "public.name", "gene.other.ids")]
rm(x)

# Additional information for library troubleshooting ===========================
orfeome_unmatched <- orfeome[is.na(orfeome$GeneID), ]
orfeome_unique <- unique(as.vector(orfeome$ORF))

# Save =========================================================================
save(orfeome, orfeome_simple, file = "rda/orfeome.rda")
write.csv(orfeome, "csv/orfeome.csv")
