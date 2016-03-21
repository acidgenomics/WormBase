pkg <- c("RCurl")
lapply(pkg, require, character.only = TRUE)
if (!file.exists("sources")) { dir.create("sources") }
setwd("sources")

# WormBase =====================================================================
# http://www.wormbase.org/about/release_schedule
files <- c("affy_oligo_mapping",
           "agil_oligo_mapping",
           "functional_descriptions",
           "geneIDs",
           "geneOtherIDs",
           "orthologs")
lapply(seq(along = files), function(i) {
  file <- paste(c("ftp://ftp.wormbase.org/pub/wormbase/species/c_elegans/annotation/",
                  files[i], "/c_elegans.canonical_bioproject.current.", files[i], ".txt.gz"),
                collapse = "")
  save <- paste(c(files[i], ".txt.gz"), collapse = "")
  download.file(file, save)
})
# BLASTP -----------------------------------------------------------------------
# Doesn't match folder, so need to request manually instead
download.file("ftp://ftp.wormbase.org/pub/wormbase/species/c_elegans/annotation/best_blast_hits/c_elegans.canonical_bioproject.current.best_blastp_hits.txt.gz", "best_blastp_hits.txt.gz")
# RNAi phenotypes --------------------------------------------------------------
dir <- "ftp://ftp.wormbase.org/pub/wormbase/releases/current-production-release/ONTOLOGY/"
ls <- getURL(dir, dirlistonly = TRUE, verbose = TRUE)
ls <- strsplit(ls, "\n")
ls <- ls[[1]]
grep <- grep("rnai_phenotypes_quick", ls, value = TRUE)
file <- paste(c(dir, grep), collapse = "")
download.file(file, "rnai_phenotypes.txt")
system("gzip --force rnai_phenotypes.txt")
# Wormpep IDs used for BLASTP matching -----------------------------------------
dir <- "ftp://ftp.wormbase.org/pub/wormbase/releases/current-production-release/species/c_elegans/PRJNA13758/"
ls <- getURL(dir, dirlistonly = TRUE, verbose = TRUE)
ls <- strsplit(ls, "\n")
ls <- ls[[1]]
ls
grep <- grep("wormpep_package", ls, value = TRUE)
grep
file <- paste(c(dir, grep), collapse = "")
download.file(file, "wormpep.tar.gz")
system("tar -xzf wormpep.tar.gz wormpep.table*")
file <- list.files(pattern = "wormpep.table")
file
file.rename(file, "wormpep.txt")
system("gzip --force wormpep.txt")
# Removal original wormpep file because it's large
file.remove("wormpep.tar.gz")

# PANTHER ======================================================================
dir <- "ftp://ftp.pantherdb.org/sequence_classifications/current_release/PANTHER_Sequence_Classification_files/"
ls <- getURL(dir, dirlistonly = TRUE, verbose = TRUE)
ls <- strsplit(ls, "\n")
ls <- ls[[1]]
grep <- grep("nematode_worm", ls, value = TRUE)
file <- paste(c(dir, grep), collapse = "")
download.file(file, "panther.txt")
system("gzip --force panther.txt")

# RNAi libraries ===============================================================
# Vidal (ORFeome)
# http://dharmacon.gelifesciences.com/non-mammalian-cdna-and-orf/c.-elegans-rnai/
download.file("http://dharmacon.gelifesciences.com/uploadedFiles/Resources/cernai-feeding-library.xlsx", "orfeome.xlsx")
# Ahringer
# http://www.us.lifesciences.sourcebioscience.com/clone-products/non-mammalian/c-elegans/c-elegans-rnai-library/
download.file("http://www.us.lifesciences.sourcebioscience.com/media/381254/C.%20elegans%20Database%202012.xlsx", "ahringer.xlsx")

# Ahringer RNAi library ========================================================
# # Ahringer Library
# http://www.us.lifesciences.sourcebioscience.com/clone-products/non-mammalian/c-elegans/c-elegans-rnai-library/
download.file("http://www.us.lifesciences.sourcebioscience.com/media/381254/C.%20elegans%20Database%202012.xlsx", "ahringer.xlsx")

setwd("../")
