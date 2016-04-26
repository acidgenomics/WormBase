pkg <- c("RCurl")
source("R/bioc_packages.R")
pkg <- c("R.utils")
source("R/cran_packages.R")
save_dir <- "source_data"
wormbase_dir <- file.path(save_dir, "wormbase")
if (!file.exists(save_dir)) {
  dir.create(save_dir)
}
if (!file.exists(wormbase_dir)) {
  dir.create(wormbase_dir)
}

# WormBase =====================================================================
# http://www.wormbase.org/about/release_schedule
files <- c("affy_oligo_mapping",
           "agil_oligo_mapping",
           "functional_descriptions",
           "geneIDs",
           "geneOtherIDs",
           "orthologs")
invisible(lapply(seq(along = files), function(i) {
  file_name <- paste0(files[i], ".txt.gz")
  file <- paste0("ftp://ftp.wormbase.org/pub/wormbase/species/c_elegans/annotation/",
                  files[i], "/c_elegans.canonical_bioproject.current.", file_name)
  save <- file.path(wormbase_dir, paste0(files[i], ".txt.gz"))
  download.file(file, save)
}))

# Manually request blastp file due to naming
download.file("ftp://ftp.wormbase.org/pub/wormbase/species/c_elegans/annotation/best_blast_hits/c_elegans.canonical_bioproject.current.best_blastp_hits.txt.gz", file.path(wormbase_dir, "best_blastp_hits.txt.gz"))

# RNAi phenotypes
ftp_dir <- "ftp://ftp.wormbase.org/pub/wormbase/releases/current-production-release/ONTOLOGY/"
ls <- getURL(ftp_dir, dirlistonly = TRUE)
ls <- strsplit(ls, "\n")
ls <- ls[[1]]
grep <- grep("rnai_phenotypes_quick", ls, value = TRUE)
file <- paste0(ftp_dir, grep)
download.file(file, file.path(wormbase_dir, "rnai_phenotypes.txt"))
gzip(file.path(wormbase_dir, "rnai_phenotypes.txt"), overwrite = TRUE)

# Wormpep IDs used for BLASTP matching
ftp_dir <- "ftp://ftp.wormbase.org/pub/wormbase/releases/current-production-release/species/c_elegans/PRJNA13758/"
ls <- getURL(ftp_dir, dirlistonly = TRUE)
ls <- strsplit(ls, "\n")
ls <- ls[[1]]
grep <- grep("wormpep_package", ls, value = TRUE)
file <- paste0(ftp_dir, grep)
download.file(file, file.path(wormbase_dir, "wormpep.tar.gz"))
# Extract wormpep.table specifically
# This will output to the current working directory
system(paste0(
  "tar -xzf ",
  file.path(wormbase_dir, "wormpep.tar.gz"),
  " ",
  "wormpep.table*"
))
file <- list.files(pattern = "wormpep.table")
file.rename(file, file.path(wormbase_dir, "wormpep.txt"))
gzip(file.path(wormbase_dir, "wormpep.txt"), overwrite = TRUE)
# Remove original wormpep file because it's large
file.remove(file.path(wormbase_dir, "wormpep.tar.gz"))

# PANTHER ======================================================================
ftp_dir <- "ftp://ftp.pantherdb.org/sequence_classifications/current_release/PANTHER_Sequence_Classification_files/"
ls <- getURL(ftp_dir, dirlistonly = TRUE)
ls <- strsplit(ls, "\n")
ls <- ls[[1]]
grep <- grep("nematode_worm", ls, value = TRUE)
file <- paste0(ftp_dir, grep)
download.file(file, file.path(save_dir, "panther.txt"))
gzip(file.path(save_dir, "panther.txt"), overwrite = TRUE)

# RNAi libraries ===============================================================
# ORFeome (Vidal)
# http://dharmacon.gelifesciences.com/non-mammalian-cdna-and-orf/c.-elegans-rnai/
download.file("http://dharmacon.gelifesciences.com/uploadedFiles/Resources/cernai-feeding-library.xlsx",
              file.path(save_dir, "rnai_orfeome.xlsx"))
# Ahringer
# http://www.us.lifesciences.sourcebioscience.com/clone-products/non-mammalian/c-elegans/c-elegans-rnai-library/
download.file("http://www.us.lifesciences.sourcebioscience.com/media/381254/C.%20elegans%20Database%202012.xlsx",
              file.path(save_dir, "rnai_ahringer.xlsx"))

warnings()
