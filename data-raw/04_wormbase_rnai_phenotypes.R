library(plyr)
library(readr)
library(stringr)

# Load and set column names ====================================================
input <- read_delim(file.path("data-raw", "wormbase", "rnai_phenotypes.txt.gz"),
                    delim = "\t",
                    col_names = FALSE)
colnames(input) <- c("geneID", "ORF", "rnaiPhenotypes")
rownames(input) <- input$geneID

# Sort RNAi phenotypes alphabetically ==========================================
x <- input
x <- lapply(seq(along = rownames(x)), function(i) {
  split <- strsplit(as.character(x[i, "rnaiPhenotypes"]), ", ")
  vec <- split[[1]]
  vec <- unique(vec)
  vec <- sort(vec)
  paste(vec, collapse = " // ")
})
x <- unlist(x)
names(x) <- rownames(input)
sorted <- x
rm(x)

# Add the sorted phenotypes back ===============================================
x <- cbind(input, sorted)
rm(sorted)
load("data/geneIDRows.rda")
x <- x[geneIDRows, ]
x$rnaiPhenotypes <- NULL
rownames(x) <- geneIDRows
x$geneID <- NULL
x$ORF <- NULL
colnames(x) <- "rnaiPhenotypes"
rnaiPhenotypes <- x
rm(input, x)

warnings()
