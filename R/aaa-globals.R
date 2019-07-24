globalVariables(".")

bioproject <- "PRJNA13758"
genePattern <- "WBGene\\d{8}"
userAgent <- "https://steinbaugh.com/wormbase/"

## WS270, 271 description files are malformed.
versionArg <- quote(
    getOption(x = "wormbase.version", default = "WS269")
)
versionPattern <- "^WS\\d{3}$"
