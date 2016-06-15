library(biomaRt)
library(plyr)
library(R.utils)

# Connect to Biomart ===========================================================
# `entrezgene` = Entrez identifier
# `external_gene_name` = Ensembl public name
# `wormbase_locus` = WormBase public name
# Use `wormbase_gene_seq_name` for clean sequence identifier
mart <- useMart("ensembl", "celegans_gene_ensembl")
biomartOptions <- listAttributes(mart)

# Simple gene length info ======================================================
df <- getBM(mart = mart,
            attributes = c("ensembl_gene_id",
                           "gene_biotype",
                           "chromosome_name",
                           "start_position",
                           "end_position",
                           "strand",
                           "description"))
colnames(df) <- toCamelCase(colnames(df), split = "_")
rownames(df) <- df$ensemblGeneId
load("data/geneIdRows.rda")
df <- df[geneIdRows, ]
df$ensemblGeneId <- NULL
basic <- df
rm(df)

# Entrez identifiers ===========================================================
df <- getBM(mart = mart,
            attributes = c("ensembl_gene_id",
                           "entrezgene"))
df <- ddply(df, .(ensembl_gene_id), summarize,
            entrezgene = paste(sort(unique(entrezgene)), collapse = ", "))
colnames(df) <- toCamelCase(colnames(df), split = "_")
colnames(df)[colnames(df) == "entrezgene"] <- "entrezGeneId"
rownames(df) <- df$ensemblGeneId
df <- df[geneIdRows, ]
df$ensemblGeneId <- NULL
entrezGeneId <- df
rm(df)

# Refseq identifiers ===========================================================
df <- getBM(mart = mart,
            attributes = c("ensembl_gene_id",
                           "refseq_mrna",
                           "refseq_ncrna"))
df <- ddply(df, .(ensembl_gene_id), summarize,
            refseq_mrna = paste(sort(unique(refseq_mrna)), collapse = ", "),
            refseq_ncrna = paste(sort(unique(refseq_ncrna)), collapse = ", "))
colnames(df) <- toCamelCase(colnames(df), split = "_")
rownames(df) <- df$ensemblGeneId
df <- df[geneIdRows, ]
df$ensemblGeneId <- NULL
refseq <- df
rm(df)

# UniProt identifiers ==========================================================
df <- getBM(mart = mart,
            attributes = c("ensembl_gene_id",
                           "uniprot_sptrembl",
                           "uniprot_swissprot"))
df <- ddply(df, .(ensembl_gene_id), summarize,
            uniprot_sptrembl = paste(sort(unique(uniprot_sptrembl)), collapse = ", "),
            uniprot_swissprot = paste(sort(unique(uniprot_swissprot)), collapse = ", "))
colnames(df) <- toCamelCase(colnames(df), split = "_")
rownames(df) <- df$ensemblGeneId
df <- df[geneIdRows, ]
df$ensemblGeneId <- NULL
uniprot <- df
rm(df)

# Homology =====================================================================
# df <- getBM(mart = mart,
#             attributes = c("ensembl_gene_id",
#                            "hsapiens_homolog_ensembl_gene"))
# df <- ddply(df, .(ensembl_gene_id), summarize,
#             hsapiens_homolog_ensembl_gene = paste(sort(unique(hsapiens_homolog_ensembl_gene)), collapse = ", "))
# colnames(df) <- toCamelCase(colnames(df), split = "_")
# rownames(df) <- df$ensemblGeneId
# df <- df[geneIdRows, ]
# df$ensemblGeneId <- NULL
# homology <- df
# rm(df)

# Gene Ontology ================================================================
df <- getBM(mart = mart,
            attributes = c("ensembl_gene_id",
                           "go_id",
                           "name_1006"))
df <- ddply(df, .(ensembl_gene_id), summarize,
            go_id = paste(sort(unique(go_id)),collapse = ", "),
            name_1006 = paste(sort(unique(name_1006)), collapse = " // "))
colnames(df) <- c("ensemblGeneId", "geneOntologyId", "geneOntologyName")
rownames(df) <- df$ensemblGeneId
df$ensemblGeneId <- NULL
df <- df[geneIdRows, ]
geneOntology <- df
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
colnames(df) <- toCamelCase(colnames(df), split = "_")
rownames(df) <- df$ensemblGeneId
df <- df[geneIdRows, ]
df$ensemblGeneId <- NULL
interpro <- df
rm(df)

# Merge and save ===============================================================
df <- cbind(basic,
            entrezGeneId,
            refseq,
            uniprot,
          # homology,
            geneOntology,
            interpro)
lapply(df, class)
## df <- apply(df, 2, function(x) gsub("^(,|\\s//)\\s(.*)", "\\2", x, perl = TRUE))
## df <- apply(df, 2, function(x) gsub("(.*)(,|\\s//)\\s$", "\\1", x, perl = TRUE))

load("data-raw/gene_id.rda")
df <- df[wormbaseGeneIdRows, ]
rownames(df) <- wormbaseGeneIdRows

ensembl <- df

rm(basic,
   biomartOptions,
   df,
   entrezGeneId,
   geneOntology,
   homology,
   interpro,
   mart,
   refseq,
   uniprot)
warnings()
