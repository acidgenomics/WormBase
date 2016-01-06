rm(list = ls(all.names = T))
pkg <- c("readr","stringr")
lapply(pkg,require,character.only = T)
load("rda/GeneID.rda")

file <- read_file("sources/orthologs.txt.gz")
# convert the layout to data.frame
file <- gsub("\t"," | ",file)
file <- gsub("\n"," // ",file)
file <- gsub("= // ","\n",file)
file <- gsub(" //  // ","\t",file)
df <- read_tsv(file,comment = "#",col_names = F)
rm(file)
id <- df[,1]
head(id)
id <- as.data.frame(str_split_fixed(id, " \\| ", 2))
head(id)
df <- as.data.frame(cbind(id,df[,2]))
rm(id)
df <- df[,c(1,3)]
colnames(df) <- c("GeneID","orthologs")
rownames(df) <- df$GeneID
df$GeneID <- NULL

hsapiens.all <- list()
mmusculus.all <- list()
hsapiens.id <- vector()
hsapiens.name <- vector()
mmusculus.id <- vector()
mmusculus.name <- vector()

for (i in 1:nrow(df)) {
	gene <- rownames(df)[i]
	split1 <- strsplit(as.character(df[i,"orthologs"])," // ")
	# hsapiens
	hsapiens.all[[gene]] <- split1[[1]][grepl("Homo sapiens",split1[[1]])]
	if (length(hsapiens.all[[gene]]) > 0) {
		id <- vector()
		name <- vector()
		for (j in 1:length(hsapiens.all[[gene]])) {
			split2 <- strsplit(as.character(hsapiens.all[[gene]][j])," \\| ")
			id <- append(id, split2[[1]][2])
			name <- append(name, split2[[1]][3])
		}
		rm(j)
		id <- unique(id)
		id <- sort(id)
		id <- paste(id,collapse = ",")
		hsapiens.id[i] <- id
		rm(id)
		name <- unique(name)
		name <- sort(name)
		name <- paste(name,collapse = ",")
		hsapiens.name[i] <- name
		rm(name)
	} else {
		hsapiens.id[i] <- NA
		hsapiens.name[i] <- NA
	}
	#!!! duplicate code, write a function instead?
	# mmusculus
	mmusculus.all[[gene]] <- split1[[1]][grepl("Homo sapiens",split1[[1]])]
	if (length(mmusculus.all[[gene]]) > 0) {
		id <- vector()
		name <- vector()
		for (j in 1:length(mmusculus.all[[gene]])) {
			split2 <- strsplit(as.character(mmusculus.all[[gene]][j])," \\| ")
			id <- append(id, split2[[1]][2])
			name <- append(name, split2[[1]][3])
		}
		rm(j)
		id <- unique(id)
		id <- sort(id)
		id <- paste(id,collapse = ",")
		mmusculus.id[i] <- id
		rm(id)
		name <- unique(name)
		name <- sort(name)
		name <- paste(name,collapse = ",")
		mmusculus.name[i] <- name
		rm(name)
	} else {
		mmusculus.id[i] <- NA
		mmusculus.name[i] <- NA
	}
}
rm(i,split1,split2)

hsapiens <- as.data.frame(cbind(hsapiens.id,hsapiens.name))
#!!! length(hsapiens.all)
rownames(hsapiens) <- names(hsapiens.all)
hsapiens <- hsapiens[GeneID.vec,]
mmusculus <- as.data.frame(cbind(mmusculus.id,mmusculus.name))
#!!! length(mmusculus.all)
rownames(mmusculus) <- names(mmusculus.all)
mmusculus <- mmusculus[GeneID.vec,]
orthologs <- cbind(hsapiens,mmusculus)
colnames(orthologs) <- c("hsapiens.homolog.wormbase.id",
												 "hsapiens.homolog.wormbase.name",
												 "mmusculus.homolog.wormbase.id",
												 "mmusculus.homolog.wormbase.name")

save(orthologs, file = "rda/orthologs.rda")
