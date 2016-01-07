rm(list = ls(all.names = T))
if (!file.exists("csv")) { dir.create("csv") }
if (!file.exists("rda")) { dir.create("rda") }

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
source("sources.R")

datasets <- c("GeneID",
							"description",
							"rnai.phenotypes",
							"blastp",
							"orthologs",
							"biomart",
							"panther")

for (i in 1:length(datasets)) {
	file <- paste(c(datasets[i],".R"), collapse = "")
	source(file)
}

# load the saved values
for (i in 1:length(datasets)) {
	file <- paste(c("rda/",datasets[i],".rda"), collapse = "")
	load(file)
}

# compile
df <- data.frame()
df <- do.call(cbind, mget(datasets))
# clean up column names after cbind
colnames(df) <- gsub("GeneID.", "", colnames(df))
# done, now export
metadata <- df
write.csv(metadata, "csv/metadata.csv", row.names = F)
colnames <- colnames(metadata)
colnames
write(colnames,"colnames.txt",sep = "\n")

# simple version
metadata.simple <- df[,c("GeneID","ORF","public.name")]
write.csv(metadata.simple, "csv/metadata.simple.csv", row.names = F)

# rownames by ORF instead of GeneID (Wormbase ID)
metadata.ORF <- df[,c("ORF","GeneID","public.name")]
metadata.ORF <- metadata.ORF[!duplicated(metadata.ORF$ORF),]
metadata.ORF <- subset(metadata.ORF, !is.na(metadata.ORF$ORF))
rownames(metadata.ORF) <- metadata.ORF$ORF
write.csv(metadata.ORF, "csv/metadata.ORF.csv", row.names = F)

save(metadata,metadata.ORF,metadata.simple, file = "rda/metadata.rda")

# create CSV subsets
for (i in 1:length(datasets)) {
	df <- mget(datasets[i])[[1]]
	file <- paste(c("csv/",datasets[i],".csv"), collapse = "")
	write.csv(df, file)
}

# update ORFome RNAi metadata for screening info
# be sure to run last -- CPU intensive and requires compiled metadata.rda
source("orfeome.R")

# gzip CSV files to save disk space
system("gzip --force csv/*.csv")
