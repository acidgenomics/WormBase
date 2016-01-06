rm(list = ls(all.names = T))
pkg <- c("plyr")
lapply(pkg,require,character.only = T)
load("rda/GeneID.rda")

# Get the highest match for each peptide
input <- read.csv("sources/best_blastp_hits.txt.gz", header = FALSE)
df <- input[,c(1,4,5)]
colnames(df) <- c("PepID","ensembl","p")
# filter for only ENSEMBL info
grep <- grepl("ENSEMBL",df$ensembl)
df <- df[grep,]
rm(grep)
# remove "ENSEMBL:" from column
df$ensembl <- substr(df$ensembl, 9, 23)
# now sort by P value
df <- df[order(df$p, df$PepID),]
df <- df[!duplicated(df$PepID),]
rownames(df) <- df$PepID
blastp.scores <- df
rm(df,input)

# map peptides to WormBase GeneID
input <- readLines("sources/wormpep.txt.gz")
input <- strsplit(input,"\n")
wormpep <- lapply(input, function(x) {
	x <- gsub("^.*\t(CE[0-9]+\tWBGene[0-9]+).*$", "\\1", x, perl = T)
	y <- strsplit(x, "\t")
	x <- y[[1]]
})
head(wormpep)
df <- data.frame(do.call("rbind", wormpep))
rm(wormpep)
colnames(df) <- c("PepID","GeneID")
PepID <- df

# pull ensembl IDs and p values based on PepID
vec <- as.vector(PepID$PepID)
ensembl <- blastp.scores[vec,c("ensembl","p")]
df <- cbind(df,ensembl)
rm(ensembl)

# collapse the PepIDs for each GeneID (this must come before p value subsetting)
# peptides <- df[,c("GeneID","PepID")]
# peptides <- ddply(peptides,.(GeneID),summarize,
# 						PepID = paste(sort(unique(PepID)),collapse = ","))
# rownames(peptides) <- peptides$GeneID

# subset only the top blastp with ensembl match
df <- df[order(df$p, df$GeneID, df$PepID),]
df <- df[!duplicated(df$GeneID),]
df <- df[!is.na(df$ensembl),]
rownames(df) <- df$GeneID
# clean up the names for binding
df$GeneID <- NULL

# set rows to metadata df
df <- df[GeneID.vec,]
blastp <- df
rm(df,input)

save(blastp, file = "rda/blastp.rda")
