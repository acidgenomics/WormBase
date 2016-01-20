rm(list = ls(all.names = T))
pkg <- c("plyr", "stringr")
lapply(pkg, require, character.only = T)
load("rda/GeneID.rda")

df <- read.delim("sources/rnai_phenotypes.txt.gz", header = F, row.names = 1)
colnames(df) <- c("ORF", "rnai.phenotypes")
rnai <- vector()
#!!! USE OTHER METHOD
for (i in 1:nrow(df)) {
  gene <- rownames(df)[i]
  split <- strsplit(as.character(df[i, "rnai.phenotypes"]), ", ")
  vec <- split[[1]]
  vec <- unique(vec)
  vec <- sort(vec)
  rnai[i] <- paste(vec, collapse = " // ")
}
df <- cbind(df, rnai)
df <- df[GeneID.vec, ]
df <- df[, "rnai"]

rnai.phenotypes <- df
save(rnai.phenotypes, file = "rda/rnai_phenotypes.rda")
