load("rda/GeneID.rda")

df <- read.delim("sources/functional_descriptions.txt.gz",
                 header = F,
                 skip = 4, # bad header tag delims, set manually
                 na.strings = "none available")

# fix the column headers
header <- readLines("sources/functional_descriptions.txt.gz", n = 4)
header <- header[4]
header <- strsplit(header, " ")
colnames(df) <- header[[1]]
rm(header)

colnames(df) <- gsub("_", ".", colnames(df))
rownames(df) <- df$gene.id
df$gene.id <- NULL

# select the columns desired
# use public_name and molecular_name from GeneID.R instead, so discard here
df <- df[, c("gene.class.description",
            "concise.description",
            "provisional.description",
            "automated.description")]
# clean up column names
colnames(df) <- gsub(".description", "", colnames(df))
df <- df[GeneID_vec, ]
description <- df
rm(df)

save(description, file = "rda/description.rda")
