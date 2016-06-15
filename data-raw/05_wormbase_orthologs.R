library(readr)
library(stringr)

# Convert the orthologs file to R compatible data frame ========================
file <- read_file(file.path("data-raw", "wormbase", "orthologs.txt.gz"))
file <- gsub("\t", " | ", file)
file <- gsub("\n", " // ", file)
file <- gsub("= // ", "\n", file)
file <- gsub(" //  // ", "\t", file)
df <- read_tsv(file, comment = "#", col_names = FALSE)
rm(file)
id <- df[, 1]
head(id)
id <- as.data.frame(str_split_fixed(id, " \\| ", 2))
head(id)
df <- as.data.frame(cbind(id, df[, 2]))
rm(id)
df <- df[, c(1, 3)]
colnames(df) <- c("geneID", "orthologs")
rownames(df) <- df$geneID
df$geneID <- NULL

# Now run through and match orthologs ==========================================
hsapiensAll <- list()
hsapiensID <- vector()
hsapiensName <- vector()
for (i in 1:nrow(df)) {
  gene <- rownames(df)[i]
  split1 <- strsplit(as.character(df[i, "orthologs"]), " // ")
  hsapiensAll[[gene]] <- split1[[1]][grepl("Homo sapiens", split1[[1]])]
  if (length(hsapiensAll[[gene]]) > 0) {
    names <- names(hsapiensAll[[gene]])
    id <- vector()
    name <- vector()
    for (j in 1:length(hsapiensAll[[gene]])) {
      split2 <- strsplit(as.character(hsapiensAll[[gene]][j]), " \\| ")
      id <- append(id, split2[[1]][2])
      name <- append(name, split2[[1]][3])
    }
    id <- unique(id)
    id <- sort(id)
    id <- paste(id, collapse = ", ")
    hsapiensID[i] <- id
    name <- unique(name)
    name <- sort(name)
    name <- paste(name, collapse = ", ")
    hsapiensName[i] <- name
  } else {
    hsapiensID[i] <- NA
    hsapiensName[i] <- NA
  }
}
rm(gene, i, id, j, name, names, split1, split2)

# Final data frame cleanup =====================================================
hsapiens <- data.frame(cbind(hsapiensID, hsapiensName))
rownames(hsapiens) <- names(hsapiensAll)
load("data/geneIDRows.rda")
hsapiens <- hsapiens[geneIDRows, ]
orthologs <- hsapiens
rownames(orthologs) <- geneIDRows
rm(df, hsapiens, hsapiensAll, hsapiensID, hsapiensName)

warnings()
