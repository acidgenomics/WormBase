pkg <- c("plyr", "stringr")
lapply(pkg, require, character.only = TRUE)
load("rda/GeneID.rda")
# Load and set column names ====================================================
input <- read.delim("sources/rnai_phenotypes.txt.gz",
                    header = FALSE, row.names = 1)
colnames(input) <- c("ORF", "rnai.phenotypes")
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
rm(x)
save(rnai_phenotypes, file = "rda/rnai_phenotypes.rda")
rm(input)
warnings()
