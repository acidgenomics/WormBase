#' wormbase
#'
#' *C. elegans* genome annotations from WormBase.
#'
#' @importFrom rlang !! !!! .data abort inform warn sym syms
#' @importFrom utils globalVariables
"_PACKAGE"



globalVariables(".")
bioproject <- "PRJNA13758"
defaultCol <- c("gene", "sequence", "name")
genePattern <- "WBGene\\d{8}"
userAgent <- "http://steinbaugh.com/wormbase"
versionPattern <- "^WS\\d{3}$"
