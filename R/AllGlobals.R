# Canonical reference sequence:
#
# PRJNA13758
# https://www.ncbi.nlm.nih.gov/bioproject/?term=PRJNA13758
# Caenorhabditis elegans sequencing consortium project (2005)
#
# Other sequencing projects:
#
# PRJEB28388
# https://www.ncbi.nlm.nih.gov/bioproject/?term=PRJEB28388
# Caenorhabditis elegans strain VC2010 genome sequencing project (2018)
#
# PRJNA275000
# https://www.ncbi.nlm.nih.gov/bioproject/?term=PRJNA275000
# Caenorhabditis elegans Hawaiian strain CB4856 genome assembly (2015)

.bioproject <- "PRJNA13758"
.genePattern <- "WBGene\\d{8}"
.userAgent <- "https://r.acidgenomics.com/packages/wormbase/"
.versionArg <- quote(getOption(x = "wormbase.version", default = NULL))
