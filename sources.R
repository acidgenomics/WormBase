pkg <- c("RCurl")
lapply(pkg, require, character.only = T)

if (!file.exists("sources")) { dir.create("sources") }
setwd("sources")

# WormBase ====================================================================
# http://www.wormbase.org/about/release_schedule
files <- c("affy_oligo_mapping", "agil_oligo_mapping", "geneIDs",
           "functional_descriptions", "orthologs")
lapply(seq(along = files), function(i) {
  file <- paste(c("ftp://ftp.wormbase.org/pub/wormbase/species/c_elegans/annotation/",
                  files[i], "/c_elegans.canonical_bioproject.current.", files[i], ".txt.gz"),
                collapse = "")
  save <- paste(c(files[i], ".txt.gz"), collapse = "")
  download.file(file, save)
})

# BLASTP (doesn't match folder, so request manually instead)
download.file("ftp://ftp.wormbase.org/pub/wormbase/species/c_elegans/annotation/best_blast_hits/c_elegans.canonical_bioproject.current.best_blastp_hits.txt.gz", "best_blastp_hits.txt.gz")

# RNAi phenotypes
dir <- "ftp://ftp.wormbase.org/pub/wormbase/releases/current-production-release/ONTOLOGY/"
ls <- getURL(dir, dirlistonly = T, verbose = T)
ls <- strsplit(ls, "\n")
ls <- ls[[1]]
grep <- grep("rnai_phenotypes_quick", ls, value = T)
file <- paste(c(dir, grep), collapse = "")
download.file(file, "rnai_phenotypes.txt")
system("gzip --force rnai_phenotypes.txt")

# Wormpep IDs used for BLASTP matching
#ftp://ftp.wormbase.org//pub/wormbase/releases/WS251/species/c_elegans/PRJNA13758/c_elegans.PRJNA13758.WS251.wormpep_package.tar.gz
dir <- "ftp://ftp.wormbase.org//pub/wormbase/releases/current-production-release/species/c_elegans/PRJNA13758/"
ls <- getURL(dir, dirlistonly = T, verbose = T)
ls <- strsplit(ls, "\n")
ls <- ls[[1]]
grep <- grep("wormpep_package", ls, value = T)
file <- paste(c(dir, grep), collapse = "")
download.file(file, "wormpep.tar.gz")
system("tar -ztvf wormpep.tar.gz")
system("tar -xzf wormpep.tar.gz wormpep.table*")
file.remove("wormpep.tar.gz")
file <- list.files(pattern = "wormpep.table")
file.rename(file, "wormpep.txt")
system("gzip --force wormpep.txt")

# wormpep.table
system("tar -zxvf wormpep.tar.gz")

# PANTHER =====================================================================
dir <- "ftp://ftp.pantherdb.org/sequence_classifications/current_release/PANTHER_Sequence_Classification_files/"
ls <- getURL(dir, dirlistonly = T, verbose = T)
ls <- strsplit(ls, "\n")
ls <- ls[[1]]
grep <- grep("nematode_worm", ls, value = T)
file <- paste(c(dir, grep), collapse = "")
download.file(file, "panther.txt")
system("gzip --force panther.txt")

# ORFeome RNAi library ========================================================
# http://dharmacon.gelifesciences.com/non-mammalian-cdna-and-orf/c.-elegans-rnai/
download.file("http://dharmacon.gelifesciences.com/uploadedFiles/Resources/cernai-feeding-library.xlsx", "orfeome.xlsx")

setwd("../")
