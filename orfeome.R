rm(list = ls(all.names = T))
pkg <- c("openxlsx")
lapply(pkg, require, character.only = T)

load("rda/metadata.rda")
rm(metadata, metadata.simple)

input <- read.xlsx("sources/orfeome.xlsx", sheet = 2)
df <- input[, c("ORF.ID.(WS112)",
                "Plate",
                "Row",
                "Col",
                "RNAi.well",
                "Nonv",
                "Vpep",
                "Simmer")]
names(df)[names(df) == "ORF.ID.(WS112)"] <- "ORF"

# Censors or wells without match
censored <- subset(df, is.na(RNAi.well))
no.match <- subset(df, ORF == "no match in WS112")

# Subset the censors
df <- subset(df, !is.na(RNAi.well))
df <- subset(df, ORF != "no match in WS112")
input.clean <- df

# Set plate IDs as rownames
col <- c("Plate", "Row", "Col")
ORFeomeID <- do.call(paste, c(df[col], sep = "-"))
rm(col)
ORFeomeID[1]
ORFeomeID <- gsub("^(.*)-([0-9]{1})$", "\\1-0\\2", ORFeomeID, perl = T, ignore.case = F) # pad zeros
ORFeomeID[1]
ORFeomeID <- gsub("^([0-9]{5})-([A-Z]{1})-([0-9]{2})$", "\\1@\\2\\3", ORFeomeID, perl = T, ignore.case = F)
ORFeomeID[1]
df <- cbind(ORFeomeID, df)
rownames(df) <- df$ORFeomeID
orfeome.valid <- df

# Since there are duplicate ORFs per well, we must loop from metadata.ORF
orf <- as.vector(df$ORF)
list <- list()
list <- lapply(seq(along = orf), function(i) {
  metadata.ORF[orf[i], c(2, 3)]
})
# This step is cpu expensive, any way to speed up?
df <- data.frame(do.call("rbind", list))
rownames(df) <- NULL
orf.to.GeneID <- df

# bind the matches back to the valid orfeome df
df <- cbind(orf.to.GeneID, orfeome.valid)
rownames(df) <- as.vector(df$ORFeomeID)
df$ORFeomeID <- NULL
colnames(df)
df <- df[, c("RNAi.well", "ORF", "GeneID", "public.name",
             "Nonv", "Vpep", "Simmer")]
orfeome <- df

orfeome.unmatched <- orfeome[is.na(orfeome$GeneID), ]
orfeome.simple <- orfeome[, c(2:4)]
orfeome.unique <- unique(as.vector(orfeome$ORF))

save(orfeome, orfeome.simple, file = "rda/orfeome.rda")
write.csv(orfeome, "csv/orfeome.csv")
