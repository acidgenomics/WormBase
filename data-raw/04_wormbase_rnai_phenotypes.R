library(plyr)
library(readr)
library(stringr)

# Load and set column names ====================================================
input <- read_delim(file.path("data-raw", "wormbase", "rnai_phenotypes.txt.gz"),
                    delim = "\t",
                    col_names = FALSE)
colnames(input) <- c("GeneID", "ORF", "rnai.phenotypes")
rownames(input) <- input$GeneID

# Sort RNAi phenotypes alphabetically ==========================================
x <- input
x <- lapply(seq(along = rownames(x)), function(i) {
  split <- strsplit(as.character(x[i, "rnai.phenotypes"]), ", ")
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
x <- x[GeneID_vec, ]
x$rnai.phenotypes <- NULL
rownames(x) <- GeneID_vec
x$GeneID <- NULL
x$ORF <- NULL
colnames(x) <- "rnai.phenotypes"
rnai_phenotypes <- x
rm(input, x)

devtools::use_data(rnai_phenotypes, overwrite = TRUE)
warnings()
