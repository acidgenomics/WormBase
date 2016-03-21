pkg <- c("readr", "stringr")
lapply(pkg, require, character.only = TRUE)
load("rda/GeneID.rda")

# Convert the orthologs file to R compatible data frame ========================
file <- read_file("sources/orthologs.txt.gz")
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
colnames(df) <- c("GeneID", "orthologs")
rownames(df) <- df$GeneID
df$GeneID <- NULL

# Now run through and match orthologs ==========================================
hsapiens.all <- list()
hsapiens.id <- vector()
hsapiens.name <- vector()

for (i in 1:nrow(df)) {
  gene <- rownames(df)[i]
  split1 <- strsplit(as.character(df[i, "orthologs"]), " // ")
  hsapiens.all[[gene]] <- split1[[1]][grepl("Homo sapiens", split1[[1]])]
  if (length(hsapiens.all[[gene]]) > 0) {
    names <- names(hsapiens.all[[gene]])
    id <- vector()
    name <- vector()
    for (j in 1:length(hsapiens.all[[gene]])) {
      split2 <- strsplit(as.character(hsapiens.all[[gene]][j]), " \\| ")
      id <- append(id, split2[[1]][2])
      name <- append(name, split2[[1]][3])
    }
    rm(j)
    id <- unique(id)
    id <- sort(id)
    id <- paste(id, collapse = ", ")
    hsapiens.id[i] <- id
    rm(id)
    name <- unique(name)
    name <- sort(name)
    name <- paste(name, collapse = ", ")
    hsapiens.name[i] <- name
    rm(name)
  } else {
    hsapiens.id[i] <- NA
    hsapiens.name[i] <- NA
  }
}
rm(i, split1, split2)

hsapiens <- as.data.frame(cbind(hsapiens.id, hsapiens.name))
rownames(hsapiens) <- names(hsapiens.all)
colnames(hsapiens) <- c("hsapiens.homolog.wormbase.id",
                        "hsapiens.homolog.wormbase.name")
hsapiens <- hsapiens[GeneID_vec, ]
orthologs <- hsapiens
rownames(orthologs) <- GeneID_vec
rm(hsapiens)

save(orthologs, file = "rda/orthologs.rda")
