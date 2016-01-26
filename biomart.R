pkg <- c("biomaRt", "plyr")
lapply(pkg, require, character.only = T)
load("rda/GeneID.rda")

# entrezgene = entrez ID
# external_gene_name = ensembl public name
# wormbase_locus = wormbase public name
# use wormbase_gene_seq_name for clean sequence ID

mart <- useMart("ensembl", "celegans_gene_ensembl")
biomart.options <- listAttributes(mart)

# musculus <- useMart("ensembl","mmusculus_gene_ensembl")
# sapiens <- useMart("ensembl","hsapiens_gene_ensembl")

# Simple gene length info ------------------------------------------------------
df <- getBM(mart = mart,
            attributes = c("ensembl_gene_id",
                           "gene_biotype",
                           "chromosome_name",
                           "start_position",
                           "end_position",
                           "strand",
                           "description"))
rownames(df) <- df$ensembl_gene_id
df$ensembl_gene_id <- NULL
basic <- df[GeneID.vec, ]
rm(df)

# Entrez IDs -------------------------------------------------------------------
df <- getBM(mart = mart,
            attributes = c("ensembl_gene_id",
                           "entrezgene"))
df <- ddply(df, .(ensembl_gene_id), summarize,
            entrezgene = paste(sort(unique(entrezgene)), collapse = ","))
rownames(df) <- df$ensembl_gene_id
df$ensembl_gene_id <- NULL
entrezgene <- df[GeneID.vec, ]
rm(df)

# UniProt IDs ------------------------------------------------------------------
df <- getBM(mart = mart,
            attributes = c("ensembl_gene_id",
                           "uniprot_sptrembl",
                           "uniprot_swissprot"))
df <- ddply(df, .(ensembl_gene_id), summarize,
            uniprot_sptrembl = paste(sort(unique(uniprot_sptrembl)), collapse = ","),
            uniprot_swissprot = paste(sort(unique(uniprot_swissprot)), collapse = ","))
rownames(df) <- df$ensembl_gene_id
df$ensembl_gene_id <- NULL
uniprot <- df[GeneID.vec, ]
rm(df)

# Homology ---------------------------------------------------------------------
df <- getBM(mart = mart,
            attributes = c("ensembl_gene_id",
                           "hsapiens_homolog_ensembl_gene"))
df <- ddply(df, .(ensembl_gene_id), summarize,
            hsapiens_homolog_ensembl_gene = paste(sort(unique(hsapiens_homolog_ensembl_gene)), collapse = ","))
rownames(df) <- df$ensembl_gene_id
df$ensembl_gene_id <- NULL
homology <- df[GeneID.vec, ]
rm(df)

# GO terms ---------------------------------------------------------------------
df <- getBM(mart = mart,
            attributes = c("ensembl_gene_id",
                           "go_id",
                           "name_1006"))
df <- ddply(df, .(ensembl_gene_id), summarize,
            go_id = paste(sort(unique(go_id)),collapse = ","),
            name_1006 = paste(sort(unique(name_1006)), collapse = " // "))
rownames(df) <- df$ensembl_gene_id
df$ensembl_gene_id <- NULL
colnames(df) <- c("ensembl.go.id", "ensembl.go.names")
go.terms <- df[GeneID.vec, ]
rm(df)

# Interpro ---------------------------------------------------------------------
df <- getBM(mart = mart,
            attributes = c("ensembl_gene_id",
                           "interpro",
                           "interpro_short_description",
                           "interpro_description"))
df <- ddply(df, .(ensembl_gene_id), summarize,
            interpro = paste(sort(unique(interpro)),collapse = ","),
            interpro_short_description = paste(sort(unique(interpro_short_description)), collapse = " // "),
            interpro_description = paste(sort(unique(interpro_description)), collapse = " // "))
rownames(df) <- df$ensembl_gene_id
df$ensembl_gene_id <- NULL
interpro <- df[GeneID.vec, ]
rm(df)

# Merge everything together ----------------------------------------------------
df <- cbind(basic, entrezgene, uniprot, homology, go.terms, interpro)
rownames(df) <- GeneID.vec
colnames(df) <- gsub("_", ".", colnames(df))
colnames(df)[colnames(df) == "description"] <- "ensembl.description"
# Fix leading and trailing commas
df <- as.data.frame(apply(df, 2, function(x) gsub("^,(.*)", "\\1", x, perl = T)))
df <- as.data.frame(apply(df,2,function(x) gsub("(.*),$", "\\1", x, perl = T)))
biomart <- df
rm(df)

save(biomart, file = "rda/biomart.rda")
