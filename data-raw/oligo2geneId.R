file <- wormbaseFile("pcr_product2gene")
df <- readr::read_tsv(file, col_names = FALSE)
names(df) <- c("oligo", "geneId")
df$geneId <- gsub("^(WBGene[0-9]+).*", "\\1", df$geneId)
head(df)
oligo2geneId <- df
devtools::use_data(oligo2geneId, overwrite = TRUE)
