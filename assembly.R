rm(list = ls(all.names = T))
if (!file.exists("save")) { dir.create("save") }

# get files from wormbase and panther
source("downloads.R")

source("GeneID.R")
source("biomart.R")
source("descriptions.R")
source("orthologs.R")
source("panther.R")
source("rnai.phenotypes.R")

# load the saved values
load("save/GeneID.rda")
load("save/biomart.rda")
load("save/descriptions.rda")
load("save/orthologs.rda")
load("save/panther.rda")
load("save/rnai.phenotypes.rda")

# compile
df <- data.frame()
df <- cbind(GeneID,
						biomart,
						descriptions,
						rnai.phenotypes,
						orthologs,
						panther)
colnames(df)
df.all <- df

df <- df[,c("GeneID",
						"public.name",
						"ORF",
						"wormbase.status",
						"gene.biotype",
						"gene.class.description",
						"concise.description",
						"provisional.description",
						"automated.description",
						"ensembl.description",
						"hsapiens.homolog.ensembl.gene",
						"hsapiens.homolog.wormbase.id",
						"hsapiens.homolog.wormbase.name",
						"mmusculus.homolog.ensembl.gene",
						"mmusculus.homolog.wormbase.id",
						"mmusculus.homolog.wormbase.name",
						"rnai.phenotypes",
						"chromosome.name",
						"start.position",
						"end.position",
						"strand",
						"entrezgene",
						"uniprot.sptrembl", # from biomart
						"uniprot.swissprot", # from biomart
						"uniprot.kb", # from panther
						"ensembl.go.id",
						"ensembl.go.names",
						"interpro",
						"interpro.short.description",
						"interpro.description",
						"panther.sf.id",
						"panther.family.name",
						"panther.subfamily.name",
						"panther.go.bp",
						"panther.go.mf",
						"panther.go.cc",
						"panther.pc",
						"panther.pathway")]
metadata <- df
write.csv(metadata,"metadata.csv",row.names = F)

# simple
metadata.simple <- df[,c("GeneID","ORF","public.name")]
write.csv(metadata.simple,"metadata.simple.csv",row.names = F)

# rownames by ORF instead of GeneID (Wormbase ID)
metadata.ORF <- df[,c("ORF","GeneID","public.name")]
metadata.ORF <- metadata.ORF[!duplicated(metadata.ORF$ORF),]
metadata.ORF <- subset(metadata.ORF,!is.na(metadata.ORF$ORF))
rownames(metadata.ORF) <- metadata.ORF$ORF
write.csv(metadata.ORF,"metadata.ORF.csv",row.names = F)

save(metadata,metadata.ORF,metadata.simple, file = "save/metadata.rda")
save.image("save/assembly.RData")
