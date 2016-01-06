rm(list = ls(all.names = T))
pkg <- c("openxlsx")
lapply(pkg,require,character.only = T)

load("rda/metadata.rda")

input <- read.xlsx("sources/cernai-feeding-library.xlsx", sheet = 2)
df <- input
df <- subset(df, !is.na(`ORF.ID.(WS112)`))
df <- subset(df, `ORF.ID.(WS112)` != "no match in WS112")
cols <- c("Plate","Row","Col")
df$id

vec <- do.call(paste, c(df[cols], sep = "-"))
vec <- gsub("^([0-9]{5})-(.*)$", "\\1@\\2", vec, perl = T, ignore.case = F)
vec <- gsub("^(.*)-([0-9]{1})$", "\\10\\2", vec, perl = T, ignore.case = F) # pad zeros for sorting later
vec <- gsub("^(.*)-([0-9]{2})$", "\\1\\2", vec, perl = T, ignore.case = F)
head(vec)
rownames(df) <- vec
# remove columns from original df
#!!! for (co in cols) data[co] <- NULL

# get info for duplicate clones
dupes <- df[duplicated(df$`ORF.ID.(WS112)`),]

# ORF cleanup for matching
vec <- as.vector(df$`ORF.ID.(WS112)`)
# strip any isoform annotations off the end for proper matching!
vec <- gsub("^(.*)[a-z]{1}$", "\\1", vec, perl = T, ignore.case = F)
head(vec)
orf <- vec

# since there are duplicate ORFs per well, we must set a loop and pull from metadata.ORF
# alternate approach to use lapply somehow would be faster?
info <- data.frame(matrix(nrow = 0, ncol = 3))
colnames(info) <- colnames(metadata.ORF)
for (i in 1:length(orf)) {
	info <- rbind(info, metadata.ORF[orf[i],])
}
rownames(info) <- rownames(df)
info <- info[,c(2,1,3)] # flip ORF and GeneID order
orfeome <- info

save(orfeome, file = "rda/orfeome.rda")
write.csv(orfeome, "csv/orfeome.csv")
