bioproject <- "PRJNA13758"
genePattern <- "WBGene\\d{8}"
userAgent <- "https://wormbase.acidgenomics.com/"

## WS270, WS271 description files are currently malformed.
version <- "WS277"
versionArg <- quote(getOption(x = "wormbase.version", default = NULL))
versionPattern <- "^WS\\d{3}$"
