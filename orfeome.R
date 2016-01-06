rm(list = ls(all.names = T))
pkg <- c("openxlsx")
lapply(pkg,require,character.only = T)

load("rda/metadata.rda")
rm(metadata,metadata.simple)

input <- read.xlsx("sources/cernai-feeding-library.xlsx", sheet = 2)
df <- input[,c("ORF.ID.(WS112)",
							 "Plate",
							 "Row",
							 "Col",
							 "RNAi.well",
							 "Nonv",
							 "Vpep",
							 "Simmer")]
names(df)[names(df) == "ORF.ID.(WS112)"] <- "ORF"

censored <- subset(df, is.na(RNAi.well))
no.match <- subset(df, ORF == "no match in WS112")

# subset the censors
df <- subset(df, !is.na(RNAi.well))
df <- subset(df, ORF != "no match in WS112")
input.clean <- df

# set plate IDs as rownames
col <- c("Plate","Row","Col")
ORFeomeID <- do.call(paste, c(df[col], sep = "-"))
rm(col)
ORFeomeID[1]
ORFeomeID <- gsub("^(.*)-([0-9]{1})$", "\\1-0\\2", ORFeomeID, perl = T, ignore.case = F) # pad zeros
ORFeomeID[1]
ORFeomeID <- gsub("^([0-9]{5})-([A-Z]{1})-([0-9]{2})$", "\\1@\\2\\3", ORFeomeID, perl = T, ignore.case = F)
ORFeomeID[1]
df <- cbind(ORFeomeID,df)
rownames(df) <- df$ORFeomeID
orfeome.valid <- df

# since there are duplicate ORFs per well, we must set a loop and pull from metadata.ORF
list <- list()
orf <- as.vector(df$ORF)
for (i in 1:length(orf)) {
	list[[i]] <- metadata.ORF[orf[i],c(2,3)]
}
df <- data.frame(do.call("rbind", list)) # cpu expensive -- takes 4 minutes on my Mac
rownames(df) <- NULL
orf.to.GeneID <- df

# bind the matches back to the valid orfeome df
df <- cbind(orf.to.GeneID,orfeome.valid)
rownames(df) <- as.vector(df$ORFeomeID)
df$ORFeomeID <- NULL
colnames(df)
df <- df[,c("RNAi.well",
						"ORF",
						"GeneID",
						"public.name",
						"Nonv",
						"Vpep",
						"Simmer")]
orfeome <- df

orfeome.unmatched <- orfeome[is.na(orfeome$GeneID),]
orfeome.simple <- orfeome[,c(2:4)]
orfeome.unique <- unique(as.vector(orfeome$ORF))

save(orfeome,orfeome.simple, file = "rda/orfeome.rda")
write.csv(orfeome, "csv/orfeome.csv")
