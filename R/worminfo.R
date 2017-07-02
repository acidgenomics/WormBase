#' worminfo
#'
#' C. elegans genome annotations and RNAi clone mappings.
#'
#' @import basejump
#' @import Biobase
#' @import BiocGenerics
#' @import S4Vectors
#' @importFrom UniProt.ws UniProt.ws
"_PACKAGE"

globalVariables(".")

defaultCol <- c("gene", "sequence", "name")
userAgent <- "http://steinbaugh.com/worminfo/"
