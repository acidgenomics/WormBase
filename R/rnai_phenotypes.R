pkg <- c("plyr", "stringr")
source("R/bioc_packages.R")
load("rda/GeneID.rda")
# Load and set column names ====================================================
input <- read_delim("source_data/wormbase/rnai_phenotypes.txt.gz",
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
x <- data.frame(do.call("rbind", x))
colnames(x) <- "rnai.phenotypes"
sorted <- x
rm(x)
# Add the sorted phenotypes back ===============================================
x <- input
x$rnai.phenotypes <- NULL
x <- cbind(x, sorted)
rm(sorted)
x <- x[GeneID_vec, ]
rownames(x) <- GeneID_vec
x$ORF <- NULL
rnai_phenotypes <- x
rm(input, x)

save(rnai_phenotypes, file = "rda/rnai_phenotypes.rda")
warnings()
