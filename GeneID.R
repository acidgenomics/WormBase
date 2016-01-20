rm(list = ls(all.names = T))

df <- read.csv("sources/geneIDs.txt.gz", header = F, na.strings = "")
df <- df[, c(2:5)] # discard uneeded columns
colnames(df) <- c("GeneID", "public.name", "ORF", "wormbase.status")
rownames(df) <- df$GeneID
GeneID.vec <- rownames(df)
GeneID <- df
rm(df)

save(GeneID, GeneID.vec, file = "rda/GeneID.rda")
