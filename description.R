load("rda/GeneID.rda")
df <- read.delim("sources/functional_descriptions.txt.gz",
                 header = FALSE,
                 skip = 4, # bad header tag delims, set manually
                 na.strings = "none available")

# Fix the column headers =======================================================
header <- readLines("sources/functional_descriptions.txt.gz", n = 4)
header <- header[4]
header <- strsplit(header, " ")
colnames(df) <- header[[1]]
rm(header)

colnames(df) <- gsub("_", ".", colnames(df))
rownames(df) <- df$gene.id
df$gene.id <- NULL

# Select the columns desired ===================================================
# Use public_name and molecular_name from GeneID.R instead, so discard here
df <- df[, c("gene.class.description",
            "concise.description",
            "provisional.description",
            "automated.description")]
# Clean up the column names
colnames(df) <- gsub(".description", "", colnames(df))
df <- df[GeneID_vec, ]
description <- df
rm(df)

save(description, file = "rda/description.rda")
warnings()
