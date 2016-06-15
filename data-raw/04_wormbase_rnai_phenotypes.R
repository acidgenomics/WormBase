library(plyr)
library(readr)
library(stringr)

# Load and set column names ====================================================
input <- read_delim(file.path("data-raw", "wormbase", "rnai_phenotypes.txt.gz"),
                    delim = "\t",
                    col_names = FALSE)
colnames(input) <- c("geneId", "ORF", "unsorted")
rownames(input) <- input$geneId

# Sort RNAi phenotypes alphabetically ==========================================
df <- input
df <- lapply(seq(along = rownames(df)), function(x) {
  split <- strsplit(as.character(df[x, "unsorted"]), ", ")
  vec <- split[[1]]
  vec <- unique(vec)
  vec <- sort(vec)
  paste(vec, collapse = " // ")
})
df <- unlist(df)
names(df) <- rownames(input)
sorted <- df

# Add the sorted phenotypes back
df <- cbind(input, sorted)

load("data-raw/gene_id.rda")
df <- df[wormbaseGeneIdRows, ]
rownames(df) <- wormbaseGeneIdRows

# Remove unnecessary columns
df$geneId <- NULL
df$ORF <- NULL
df$unsorted <- NULL

# Set column name and save
colnames(df) <- "rnaiPhenotypes"

wormbaseRnaiPhenotypes <- df

rm(input, sorted, df)
warnings()
