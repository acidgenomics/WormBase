pkg <- c("plyr", "stringr")
lapply(pkg, require, character.only = T)
load("rda/GeneID.rda")

df <- read.delim("sources/rnai_phenotypes.txt.gz", header = F, row.names = 1)
colnames(df) <- c("ORF", "rnai.phenotypes")

rnai.ordered <- lapply(seq(along = rownames(df)), function(i) {
  gene <- rownames(df)[i]
  split <- strsplit(as.character(df[i, "rnai.phenotypes"]), ", ")
  vec <- split[[1]]
  vec <- unique(vec)
  vec <- sort(vec)
  paste(vec, collapse = " // ")
})
rnai.ordered <- data.frame(do.call("rbind", rnai.ordered))
colnames(rnai.ordered) <- "rnai.phenotypes"

df$rnai.phenotypes <- NULL
df <- cbind(df, rnai.ordered)
rm(rnai.ordered)
df <- df[GeneID.vec, ]
rownames(df) <- GeneID.vec
df$ORF <- NULL
rnai.phenotypes <- df
rm(df)

save(rnai.phenotypes, file = "rda/rnai_phenotypes.rda")
