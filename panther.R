pkg <- c("plyr", "stringr")
lapply(pkg, require, character.only = T)
load("rda/GeneID.rda")

df <- read.delim("sources/panther.txt.gz", header = F)
colnames(df) <- c("id",
                  "protein",
                  "sf.id",
                  "family.name",
                  "subfamily.name",
                  "go.mf",
                  "go.bp",
                  "go.cc",
                  "pc",
                  "pathway")
df$protein <- NULL
id <- df$id # cleanup and split below
df$id <- NULL # now safe to remove

id <- gsub("CAEEL\\|", "", id)

# Fix incorrect ID mapping in PANTHER ------------------------------------------
# ORF to WBGeneID
id <- gsub("Gene=B0303.5\\|", "WormBase=WBGene00015127\\|", id)
id <- gsub("Gene=C13B9.1\\|", "WormBase=WBGene00015732\\|", id)
id <- gsub("Gene=F23F12.11/F23F12.5\\|", "WormBase=WBGene00005075\\|", id)
id <- gsub("Gene=F52C9.6\\|", "WormBase=WBGene00018676\\|", id)
id <- gsub("Gene=F55A11.4\\|", "WormBase=WBGene00010077\\|", id)
id <- gsub("Gene=K02A2.6\\|", "WormBase=WBGene00019291\\|", id)
id <- gsub("Gene=MTCE.11\\|", "WormBase=WBGene00010959\\|", id)
id <- gsub("Gene=T07D3.8\\|", "WormBase=WBGene00020310\\|", id)
id <- gsub("Gene=WormBase=C05B10.1b\\|", "WormBase=WBGene00003043\\|", id)
id <- gsub("Gene=WormBase=C11D2.6m\\|", "WormBase=WBGene00006809\\|", id)
id <- gsub("Gene=WormBase=C14A11.1\\|", "WormBase=WBGene00006632\\|", id)
id <- gsub("Gene=WormBase=C17H12.37\\|", "WormBase=WBGene00236786\\|", id)
id <- gsub("Gene=WormBase=C17H12.6a\\|", "WormBase=WBGene00015932\\|", id)
id <- gsub("Gene=WormBase=C34D4.14f\\|", "WormBase=WBGene00016405\\|", id)
id <- gsub("Gene=WormBase=C42D4.12\\|", "WormBase=WBGene00006276\\|", id)
id <- gsub("Gene=WormBase=C42D4.13a\\|", "WormBase=WBGene00016598\\|", id)
id <- gsub("Gene=WormBase=C43G2.2a\\|", "WormBase=WBGene00016611\\|", id)
id <- gsub("Gene=WormBase=C49H3.10b\\|", "WormBase=WBGene00002080\\|", id)
id <- gsub("Gene=WormBase=C49H3.5d\\|", "WormBase=WBGene00003827\\|", id)
id <- gsub("Gene=WormBase=F08A10.1j\\|", "WormBase=WBGene00008570\\|", id)
id <- gsub("Gene=WormBase=F38A5.22\\|", "WormBase=WBGene00235391\\|", id)
id <- gsub("Gene=WormBase=F42C5.5a\\|", "WormBase=WBGene00018347\\|", id)
id <- gsub("Gene=WormBase=F45E4.3a\\|", "WormBase=WBGene00018468\\|", id)
id <- gsub("Gene=WormBase=F49E8.1b\\|", "WormBase=WBGene00018635\\|", id)
id <- gsub("Gene=WormBase=F53B2.1\\|", "WormBase=WBGene00009954\\|", id)
id <- gsub("Gene=WormBase=F53G12.9a\\|", "WormBase=WBGene00018774\\|", id)
id <- gsub("Gene=WormBase=F54E2.3g\\|", "WormBase=WBGene00004130\\|", id)
id <- gsub("Gene=WormBase=F56A6.8\\|", "WormBase=WBGene00235390\\|", id)
id <- gsub("Gene=WormBase=K02A2.7\\|", "WormBase=WBGene00005132\\|", id)
id <- gsub("Gene=WormBase=K08B4.1d\\|", "WormBase=WBGene00002245\\|", id)
id <- gsub("Gene=WormBase=K12C11.3c\\|", "WormBase=WBGene00019674\\|", id)
id <- gsub("Gene=WormBase=R05G6.10c\\|", "WormBase=WBGene00019902\\|", id)
id <- gsub("Gene=WormBase=T01B11.5a\\|", "WormBase=WBGene00006220\\|", id)
id <- gsub("Gene=WormBase=T10H4.13\\|", "WormBase=WBGene00045339\\|", id)
id <- gsub("Gene=WormBase=T22D1.12b\\|", "WormBase=WBGene00020689\\|", id)
id <- gsub("Gene=WormBase=W03F8.9b\\|", "WormBase=WBGene00020997\\|", id)
id <- gsub("Gene=WormBase=W04C9.9\\|", "WormBase=WBGene00235388\\|", id)
id <- gsub("Gene=WormBase=W09H1.2\\|", "WormBase=WBGene00001947\\|", id)
id <- gsub("Gene=WormBase=Y18H1A.12a\\|", "WormBase=WBGene00000624\\|", id)
id <- gsub("Gene=WormBase=Y18H1A.3e\\|", "WormBase=WBGene00021209\\|", id)
id <- gsub("Gene=WormBase=Y41E3.17\\|", "WormBase=WBGene00012775\\|", id)
id <- gsub("Gene=WormBase=Y42H9AR.3b\\|", "WormBase=WBGene00021538\\|", id)
id <- gsub("Gene=WormBase=Y46G5A.38\\|", "WormBase=WBGene00044043\\|", id)
id <- gsub("Gene=WormBase=Y48G1C.10a\\|", "WormBase=WBGene00021683\\|", id)
id <- gsub("Gene=WormBase=Y48G1C.2b\\|", "WormBase=WBGene00000812\\|", id)
id <- gsub("Gene=WormBase=Y48G1C.8b\\|", "WormBase=WBGene00021681\\|", id)
id <- gsub("Gene=WormBase=Y48G8AL.10a\\|", "WormBase=WBGene00021689\\|", id)
id <- gsub("Gene=WormBase=Y4C6B.3a\\|", "WormBase=WBGene00021157\\|", id)
id <- gsub("Gene=WormBase=Y52B11A.12\\|", "WormBase=WBGene00077539\\|", id)
id <- gsub("Gene=WormBase=Y65B4A.2c\\|", "WormBase=WBGene00022026\\|", id)
id <- gsub("Gene=WormBase=Y65B4A.9a\\|", "WormBase=WBGene00022032\\|", id)
id <- gsub("Gene=WormBase=Y65B4BL.5c\\|", "WormBase=WBGene00022037\\|", id)
id <- gsub("Gene=WormBase=Y65B4BR.2d\\|", "WormBase=WBGene00002393\\|", id)
id <- gsub("Gene=WormBase=Y65B4BR.5c\\|", "WormBase=WBGene00022042\\|", id) # dupe
id <- gsub("Gene=WormBase=Y71G12B.31a\\|", "WormBase=WBGene00044348\\|", id)
id <- gsub("Gene=WormBase=Y73B6BL.26b\\|", "WormBase=WBGene00022247\\|", id)
id <- gsub("Gene=WormBase=Y92H12A.1b\\|", "WormBase=WBGene00005077\\|", id)
id <- gsub("Gene=WormBase=Y92H12A.4a\\|", "WormBase=WBGene00022360\\|", id)
id <- gsub("Gene=WormBase=Y92H12A.5b\\|", "WormBase=WBGene00022361\\|", id)
id <- gsub("Gene=WormBase=Y95B8A.6c\\|", "WormBase=WBGene00022386\\|", id)
id <- gsub("Gene=WormBase=ZC123.3a\\|", "WormBase=WBGene00022518\\|", id)
id <- gsub("Gene=WormBase=ZK616.3a\\|", "WormBase=WBGene00022773\\|", id)
id <- gsub("Gene=WormBase=ZK616.65a\\|", "WormBase=WBGene00235383\\|", id)
id <- gsub("Gene=WormBase=ZK616.65b\\|", "WormBase=WBGene00235383\\|", id)
id <- gsub("Gene=WormBase=ZK616.9b\\|", "WormBase=WBGene00004992\\|", id)
id <- gsub("Gene=WormBase=ZK993.2a\\|", "WormBase=WBGene00022838\\|", id)
id <- gsub("Gene=WormBase=ZK993.5\\|", "WormBase=WBGene00236809\\|", id)
id <- gsub("Gene=Y104H12A.1/Y77E11A.5\\|", "WormBase=WBGene00022423\\|", id)
id <- gsub("Gene=Y62E10A.11\\|", "WormBase=WBGene00014938\\|", id)
# Entrez ID to WBGeneID
id <- gsub("GeneID=13182953\\|", "WormBase=WBGene00014700\\|", id) # C37A5.6
id <- gsub("GeneID=13182954\\|", "WormBase=WBGene00014699\\|", id) # C37A5.5
id <- gsub("GeneID=13191030\\|", "WormBase=WBGene00044222\\|", id) # T16G12.10
id <- gsub("GeneID=176090\\|", "WormBase=WBGene00022794\\|", id) # ZK686.4
id <- gsub("GeneID=184322\\|", "WormBase=WBGene00008661\\|", id) # F10G8.1
id <- gsub("GeneID=2565696\\|", "WormBase=WBGene00010966\\|", id) # MTCE.34
id <- gsub("GeneID=2565700\\|", "WormBase=WBGene00010964\\|", id) # MTCE.26
id <- gsub("GeneID=2565701\\|", "WormBase=WBGene00010962\\|", id) # MTCE.23
id <- gsub("GeneID=2565702\\|", "WormBase=WBGene00000829\\|", id) # MTCE.21
id <- gsub("GeneID=2565703\\|", "WormBase=WBGene00010967\\|", id) # MTCE.35
id <- gsub("GeneID=2565704\\|", "WormBase=WBGene00010960\\|", id) # MTCE.12
id <- gsub("GeneID=2565705\\|", "WormBase=WBGene00010963\\|", id) # MTCE.25

# Fix the ID mapping -----------------------------------------------------------
id <- as.data.frame(str_split_fixed(id, "\\|", 2))
colnames(id) <- c("GeneID", "uniprot.kb")
id <- as.data.frame(apply(id, 2, function(x) gsub("WormBase=", "", x, perl = T)))
id <- as.data.frame(apply(id, 2, function(x) gsub("UniProtKB=", "", x, perl = T)))
head(id)
# Recombine then remove duplicates from df, take out UniProtKB, then add back
df <- cbind(id, df)
df <- df[!duplicated(df$GeneID), ]
rownames(df) <- df$GeneID
df$GeneID <- NULL
df <- df[GeneID.vec, ]
rownames(df) <- GeneID.vec
panther <- df
rm(df)

save(panther, file = "rda/panther.rda")
