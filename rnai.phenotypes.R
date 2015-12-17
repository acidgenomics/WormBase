rm(list = ls(all.names = T))
pkg <- c("plyr","stringr")
lapply(pkg,require,character.only = T)
load("save/GeneID.rda")

df <- read.delim("downloads/rnai.phenotypes.txt.gz",header = F,row.names = 1)
colnames(df) <- c("ORF","rnai.phenotypes")
rnai <- vector()
for (i in 1:nrow(df)) {
	gene <- rownames(df)[i]
	split <- strsplit(as.character(df[i,"rnai.phenotypes"]),", ")
	vec <- split[[1]]
	vec <- unique(vec)
	vec <- sort(vec)
	rnai[i] <- paste(vec,collapse = " // ")
}
df <- cbind(df,rnai)
df <- df[GeneID.vec,]
df <- df[,"rnai"]

rnai.phenotypes <- df
save(rnai.phenotypes, file = "save/rnai.phenotypes.rda")
