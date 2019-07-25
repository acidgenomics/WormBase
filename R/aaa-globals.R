globalVariables(".")

bioproject <- "PRJNA13758"
genePattern <- "WBGene\\d{8}"
userAgent <- "https://steinbaugh.com/wormbase/"

## WS270, 271 description files are currently malformed.
version <- "WS269"
versionArg <- quote(getOption(x = "wormbase.version", default = NULL))
versionPattern <- "^WS\\d{3}$"
