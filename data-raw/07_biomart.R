# Need to convert factors to character vectors

library(biomaRt)
library(plyr)

# Connect to Biomart ===========================================================
# `entrezgene` = Entrez ID
# `external_gene_name` = Ensembl public name
# `wormbase_locus` = WormBase public name
# Use `wormbase_gene_seq_name` for clean sequence ID
mart <- useMart("ensembl", "celegans_gene_ensembl")
biomart_options <- listAttributes(mart)

# Simple gene length info ======================================================
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
basic <- df[GeneID_vec, ]
rm(df)

# Entrez IDs ===================================================================
df <- getBM(mart = mart,
            attributes = c("ensembl_gene_id",
                           "entrezgene"))
df <- ddply(df, .(ensembl_gene_id), summarize,
            entrezgene = paste(sort(unique(entrezgene)), collapse = ", "))
rownames(df) <- df$ensembl_gene_id
df$ensembl_gene_id <- NULL
entrezgene <- df[GeneID_vec, ]
rm(df)

# Refseq IDs ===================================================================
df <- getBM(mart = mart,
            attributes = c("ensembl_gene_id",
                           "refseq_mrna",
                           "refseq_ncrna"))
df <- ddply(df, .(ensembl_gene_id), summarize,
            refseq_mrna = paste(sort(unique(refseq_mrna)), collapse = ", "),
            refseq_ncrna = paste(sort(unique(refseq_ncrna)), collapse = ", "))
rownames(df) <- df$ensembl_gene_id
df$ensembl_gene_id <- NULL
refseq <- df[GeneID_vec, ]
rm(df)

# UniProt IDs ==================================================================
df <- getBM(mart = mart,
            attributes = c("ensembl_gene_id",
                           "uniprot_sptrembl",
                           "uniprot_swissprot"))
df <- ddply(df, .(ensembl_gene_id), summarize,
            uniprot_sptrembl = paste(sort(unique(uniprot_sptrembl)), collapse = ", "),
            uniprot_swissprot = paste(sort(unique(uniprot_swissprot)), collapse = ", "))
rownames(df) <- df$ensembl_gene_id
df$ensembl_gene_id <- NULL
uniprot <- df[GeneID_vec, ]
rm(df)

# Homology =====================================================================
df <- getBM(mart = mart,
            attributes = c("ensembl_gene_id",
                           "hsapiens_homolog_ensembl_gene"))
df <- ddply(df, .(ensembl_gene_id), summarize,
            hsapiens_homolog_ensembl_gene = paste(sort(unique(hsapiens_homolog_ensembl_gene)), collapse = ", "))
rownames(df) <- df$ensembl_gene_id
df$ensembl_gene_id <- NULL
homology <- df[GeneID_vec, ]
rm(df)

# GO terms =====================================================================
df <- getBM(mart = mart,
            attributes = c("ensembl_gene_id",
                           "go_id",
                           "name_1006"))
df <- ddply(df, .(ensembl_gene_id), summarize,
            go_id = paste(sort(unique(go_id)),collapse = ", "),
            name_1006 = paste(sort(unique(name_1006)), collapse = " // "))
rownames(df) <- df$ensembl_gene_id
df$ensembl_gene_id <- NULL
colnames(df) <- c("ensembl.go.id", "ensembl.go.names")
go_terms <- df[GeneID_vec, ]
rm(df)

# Interpro =====================================================================
df <- getBM(mart = mart,
            attributes = c("ensembl_gene_id",
                           "interpro",
                           "interpro_short_description",
                           "interpro_description"))
df <- ddply(df, .(ensembl_gene_id), summarize,
            interpro = paste(sort(unique(interpro)),collapse = ", "),
            interpro_short_description = paste(sort(unique(interpro_short_description)), collapse = " // "),
            interpro_description = paste(sort(unique(interpro_description)), collapse = " // "))
rownames(df) <- df$ensembl_gene_id
df$ensembl_gene_id <- NULL
interpro <- df[GeneID_vec, ]
rm(df)

# Merge and save ===============================================================
df <- cbind(basic, entrezgene, refseq, uniprot, homology, go_terms, interpro)
rownames(df) <- GeneID_vec
colnames(df) <- gsub("_", ".", colnames(df))
colnames(df)[colnames(df) == "description"] <- "ensembl.description"
# Fix leading and trailing commas
# This doesn't work properly and converts to factors...
#! df <- apply(df, 2, function(x) gsub("^(,|\\s//)\\s(.*)", "\\2", x, perl = TRUE))
#! df <- apply(df, 2, function(x) gsub("(.*)(,|\\s//)\\s$", "\\1", x, perl = TRUE))
biomart <- df
lapply(biomart, class)
rm(df)

devtools::use_data(biomart, overwrite = TRUE)
warnings()
