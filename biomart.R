rm(list = ls(all.names = T))
pkg <- c("biomaRt","plyr")
lapply(pkg,require,character.only = T)
load("save/GeneID.rda")

# biomaRt with ensembl
# entrezgene for entrez ID
# external_gene_name = ensembl public name
# wormbase_locus = wormbase public name
# use wormbase_gene_seq_name for clean sequence ID
# hs.mart <- useMart("ensembl","hsapiens_gene_ensembl")
# mm.mart <- useMart("ensembl","mmusculus_gene_ensembl")

# future additions:
# kegg_enzyme

mart <- useMart("ensembl","celegans_gene_ensembl")
biomart.options <- listAttributes(mart)
write.csv(biomart.options,"biomart.csv")

# simple gene length info without duplicates
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
basic <- df[GeneID.vec,]
rm(df)

# entrez IDs
df <- getBM(mart = mart,
						attributes = c("ensembl_gene_id",
													 "entrezgene"))
df <- ddply(df,.(ensembl_gene_id),summarize,
						entrezgene = paste(sort(unique(entrezgene)),collapse = ","))
rownames(df) <- df$ensembl_gene_id
df$ensembl_gene_id <- NULL
entrezgene <- df[GeneID.vec,]
rm(df)

# uniprot IDs
df <- getBM(mart = mart,
						attributes = c("ensembl_gene_id",
													 "uniprot_sptrembl",
													 "uniprot_swissprot"))
df <- ddply(df,.(ensembl_gene_id),summarize,
						uniprot_sptrembl = paste(sort(unique(uniprot_sptrembl)),collapse = ","),
						uniprot_swissprot = paste(sort(unique(uniprot_swissprot)),collapse = ","))
rownames(df) <- df$ensembl_gene_id
df$ensembl_gene_id <- NULL
uniprot <- df[GeneID.vec,]
rm(df)

# homology
df <- getBM(mart = mart,
						attributes = c("ensembl_gene_id",
													 "hsapiens_homolog_ensembl_gene",
													 "mmusculus_homolog_ensembl_gene"))
df <- ddply(df,.(ensembl_gene_id),summarize,
						hsapiens_homolog_ensembl_gene = paste(sort(unique(hsapiens_homolog_ensembl_gene)),collapse = ","),
						mmusculus_homolog_ensembl_gene = paste(sort(unique(mmusculus_homolog_ensembl_gene)),collapse = ","))
rownames(df) <- df$ensembl_gene_id
df$ensembl_gene_id <- NULL
homology <- df[GeneID.vec,]
rm(df)

# GO terms
df <- getBM(mart = mart,
						attributes = c("ensembl_gene_id",
													 "go_id",
													 "name_1006"))
df <- ddply(df,.(ensembl_gene_id),summarize,
						go_id = paste(sort(unique(go_id)),collapse = ","),
						name_1006 = paste(sort(unique(name_1006)),collapse = " // "))
rownames(df) <- df$ensembl_gene_id
df$ensembl_gene_id <- NULL
colnames(df) <- c("ensembl.go.id","ensembl.go.names")
go.terms <- df[GeneID.vec,]
rm(df)

# interpro
df <- getBM(mart = mart,
						attributes = c("ensembl_gene_id",
													 "interpro",
													 "interpro_short_description",
													 "interpro_description"))
df <- ddply(df,.(ensembl_gene_id),summarize,
						interpro = paste(sort(unique(interpro)),collapse = ","),
						interpro_short_description = paste(sort(unique(interpro_short_description)),collapse = " // "),
						interpro_description = paste(sort(unique(interpro_description)),collapse = " // "))
rownames(df) <- df$ensembl_gene_id
df$ensembl_gene_id <- NULL
interpro <- df[GeneID.vec,]
rm(df)

# merge
df <- cbind(basic,
						entrezgene,
						uniprot,
						homology,
						go.terms,
						interpro)
colnames(df) <- gsub("_",".",colnames(df)) # clean up titles
colnames(df)[colnames(df) == "description"] <- "ensembl.description"
# leading and trailing comma cleanup
df <- as.data.frame(apply(df,2,function(x) gsub("^,(.*)","\\1",x,perl = T))) # leading comma
df <- as.data.frame(apply(df,2,function(x) gsub("(.*),$","\\1",x,perl = T))) # trailing comma
biomart <- df
rm(df)

save(biomart, file = "save/biomart.rda")
save.image("save/biomart.RData")
