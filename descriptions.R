rm(list = ls(all.names = T))
load("save/GeneID.rda")

df <- read.delim("downloads/functional_descriptions.txt.gz",
								 comment.char = "#", # unneeded with skip (below)
								 header = F,
								 skip = 4, # bad header tag delims, set manually
								 na.strings = "none available")

# fix the column headers
header <- readLines("downloads/functional_descriptions.txt.gz",n = 4)
header <- header[4]
header <- strsplit(header," ")
colnames(df) <- header[[1]]
rm(header)

colnames(df) <- gsub("_",".",colnames(df))
rownames(df) <- df$gene.id
df$gene.id <- NULL

# select the columns desired
# use public_name and molecular_name from GeneID.R instead, so discard here
df <- df[,c("gene.class.description",
						"concise.description",
						"provisional.description",
						"automated.description")]

df <- df[GeneID.vec,]
descriptions <- df
rm(df)

save(descriptions, file = "save/descriptions.rda")
