library(readr)
library(readxl)
library(worminfo)

orf_metadata <- function(orf) {
  # Since there are duplicate ORFs per well, we must loop from metadata_ORF
  list <- list()
  list <- lapply(seq(along = orf), function(i) {
    metadata_ORF[orf[i], ]
  })
  # Converting to a data frame here will take a while
  df <- data.frame(do.call("rbind", list))
  assign("orf2geneID", df, envir = .GlobalEnv)
}

# Set up the data frame from Excel file ========================================
xlsx <- read_excel(file.path("data-raw", "rnai_orfeome.xlsx"), sheet = 2)
colnames(xlsx) <- gsub(" ", ".", colnames(xlsx))

# Select the desired columns and rename
df <- data.frame()
df <- xlsx[, c("ORF.ID.(WS112)",
               "Plate",
               "Row",
               "Col",
               "RNAi.well")]
names(df)[names(df) == "ORF.ID.(WS112)"] <- "ORF"

# Subset the bad wells
df <- subset(df, !is.na(RNAi.well))
df <- subset(df, ORF != "no match in WS112")
xlsx_converted <- df
rm(df)

# Set plate IDs as rownames ====================================================
df <- xlsx_converted
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
orf_metadata(as.vector(orfeome_valid$ORF))

# Bind the matches back to the valid orfeome data frame
df <- orfeome_valid

# Remove unnecessary plate information
df$Plate <- NULL
df$Row <- NULL
df$Col <- NULL

# Keep original ORF information from xlsx file
names(df)[names(df) == "ORF"] <- "ORF.original"

# Now we can bind the metadata
df <- cbind(df, orf2geneID)
rownames(df) <- as.vector(df$ORFeomeID)
colnames(df)
rm(orf2geneID)

# Need to fix dead ORFs
bad_orf <- subset(df, is.na(GeneID))
bad_orf <- bad_orf[, 1:3]

# Remove them from main df, we'll add back later
df <- subset(df, !is.na(GeneID))

# Get the ORF merge mappings (from WormBase WS252)
dead <- read_excel(file.path("data-raw", "rnai_orfeome_dead.xlsx"),
                   sheet = 1, na = "NA")
rownames(dead) <- dead$ORFeomeID
dead <- dead[rownames(bad_orf), ]

# Get the metadata of these merged ORFs
orf_metadata(as.vector(dead$merged.ORF.WS252))

# Bind back to main data frame
merge_orf <- cbind(bad_orf, orf2geneID)
df <- rbind(df, merge_orf)
df <- df[rownames(orfeome_valid), ]
rnai_orfeome <- df
rm(bad_orf, dead, df, merge_orf, orf2geneID)

# Additional information for library troubleshooting ===========================
rnai_orfeome_unmatched <- rnai_orfeome[is.na(rnai_orfeome$GeneID), ]
rnai_orfeome_unique <- unique(as.vector(rnai_orfeome$ORF))

# Save =========================================================================
devtools::use_data(rnai_orfeome, overwrite = TRUE)
warnings()
