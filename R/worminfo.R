#' worminfo
#'
#' C. elegans genome annotations and RNAi clone mappings.
#'
#' @import basejump
#' @importFrom stats na.omit
#' @importFrom UniProt.ws UniProt.ws
"_PACKAGE"

globalVariables(basejump::globals,
                asNamespace("worminfo"),
                add = TRUE)

defaultCol <- c("gene", "sequence", "name")
userAgent <- "http://steinbaugh.com/worminfo/"
