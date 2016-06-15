library(R.utils)
library(readr)
df <- read_delim(file.path("data-raw", "wormbase", "functional_descriptions.txt.gz"),
                 delim = "\t",
                 col_names = FALSE,
                 skip = 4, # column headers not properly tabbed
                 na = c("", "none available", "not known"))
# Fix the column headers
header <- readLines(file.path("data-raw", "wormbase", "functional_descriptions.txt.gz"), n = 4)
header <- header[4]
header <- strsplit(header, " ")
## header[[1]][1] <- "geneId"
colnames(df) <- header[[1]]
rm(header)
# Make sure there's a valid identifier
df <- df[grepl("^WBGene[0-9]{8}$", df$gene_id), ]
rownames(df) <- df$gene_id
# Use publicName and molecularName from geneId df instead
df$gene_id <- NULL
df$public_name <- NULL
df$molecular_name <- NULL
colnames(df) <- toCamelCase(colnames(df), split = "_")

load("data-raw/gene_id.rda")
df <- df[wormbaseGeneIdRows, ]
rownames(df) <- wormbaseGeneIdRows

wormbaseDescription <- df

rm(df)
warnings()
