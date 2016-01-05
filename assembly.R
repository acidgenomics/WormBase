# C. elegans metadata assembly
# Michael J. Steinbaugh, PhD
# email: mike@steinbaugh.com
# twitter: @mjsteinbaugh

# Please don't copy or fork any code without contacting me first!

rm(list = ls(all.names = T))
if (!file.exists("save")) { dir.create("save") }

# install required packages
source("http://bioconductor.org/biocLite.R")
biocLite()
biocLite("BiocUpgrade")
biocLite(c("biomaRt",
					 "plyr",
					 "RCurl",
					 "readr",
					 "stringr"))
install.packages("openxlsx", dependencies = T)

# get files from wormbase and panther
source("downloads.R")

source("GeneID.R")
source("descriptions.R")
source("biomart.R")
source("rnai.phenotypes.R")
source("blastp.R")
source("orthologs.R")
source("panther.R")

rm(list = ls(all.names = T))
# load the saved values
load("save/GeneID.rda")
load("save/descriptions.rda")
load("save/biomart.rda")
load("save/blastp.rda")
load("save/orthologs.rda")
load("save/panther.rda")
load("save/rnai.phenotypes.rda")

# compile
df <- data.frame()
df <- cbind(GeneID,
						descriptions,
						biomart,
						rnai.phenotypes,
						blastp,
						orthologs,
						panther)
colnames(df)
metadata <- df
write.csv(metadata, "metadata.csv", row.names = F)

# simple
metadata.simple <- df[,c("GeneID","ORF","public.name")]
write.csv(metadata.simple, "metadata.simple.csv", row.names = F)

# rownames by ORF instead of GeneID (Wormbase ID)
metadata.ORF <- df[,c("ORF","GeneID","public.name")]
metadata.ORF <- metadata.ORF[!duplicated(metadata.ORF$ORF),]
metadata.ORF <- subset(metadata.ORF, !is.na(metadata.ORF$ORF))
rownames(metadata.ORF) <- metadata.ORF$ORF
write.csv(metadata.ORF, "metadata.ORF.csv", row.names = F)

save(metadata,metadata.ORF,metadata.simple, file = "save/metadata.rda")
save.image("save/assembly.RData")

# compress CSV files to save disk space
system("gzip --force metadata.csv")
system("gzip --force metadata.ORF.csv")
system("gzip --force metadata.simple.csv")

# update ORFome RNAi metadata for screening info
# be sure to run last -- CPU intensive and requires compiled metadata.rda
source("orfeome.R")
