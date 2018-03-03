#' wormbase
#'
#' *C. elegans* genome annotations from WormBase.
#'
#' @importFrom rlang .data abort inform warn
#' @importFrom utils globalVariables
"_PACKAGE"

globalVariables(".")

bioproject <- "PRJNA13758"
defaultCol <- c("gene", "sequence", "name")
userAgent <- "http://steinbaugh.com/wormbase"
versionPattern <- "^WS\\d{3}$"
