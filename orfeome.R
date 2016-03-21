pkg <- c("openxlsx")
lapply(pkg, require, character.only = TRUE)
load("rda/metadata.rda")

input <- read_excel("sources/orfeome.xlsx", sheet = 2)

x <- input[, c("ORF.ID.(WS112)",
                "Plate",
                "Row",
                "Col",
                "RNAi.well",
                "Nonv",
                "Vpep",
                "Simmer")]
names(x)[names(x) == "ORF.ID.(WS112)"] <- "ORF"

# Subset the bad wells
x <- subset(x, !is.na(RNAi.well))
x <- subset(x, ORF != "no match in WS112")
input_subset <- x
rm(x)

# Set plate IDs as rownames
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

# Since there are duplicate ORFs per well, we must loop from metadata_ORF
# This will take a few minutes to run on a laptop
x <- orfeome_valid
orf <- as.vector(x$ORF)
list <- list()
list <- lapply(seq(along = orf), function(i) {
  metadata_ORF[orf[i], ]
})
x <- data.frame(do.call("rbind", list))
rownames(x) <- NULL
head(x)
ORF_to_GeneID <- x
rm(x, list, orf)

# Bind the matches back to the valid orfeome data frame
x <- data.frame()
x <- cbind(ORF_to_GeneID, orfeome_valid)
rownames(x) <- as.vector(x$ORFeomeID)
# Remove the first ORF instance (from ORF_to_GeneID)
x$ORF <- NULL
x$ORFeomeID <- NULL
colnames(x)

# Reorder the columns for better presentation
# This will remove Plate, Row, Col
x <- x[, c("RNAi.well",
           "ORF", "GeneID", "public.name",
           "Nonv", "Vpep", "Simmer")]
orfeome <- x
orfeome_simple <- x[, c("ORF", "GeneID", "public.name")]
rm(x)

# Additional information useful for library troubleshooting
orfeome_unmatched <- orfeome[is.na(orfeome$GeneID), ]
orfeome_unique <- unique(as.vector(orfeome$ORF))

save(orfeome, orfeome_simple, file = "rda/orfeome.rda")
write.csv(orfeome, "csv/orfeome.csv")
