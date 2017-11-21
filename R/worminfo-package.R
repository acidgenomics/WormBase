#' worminfo
#'
#' @importFrom magrittr %>%
#' @importFrom rlang .data
#'
#' C. elegans genome annotations and RNAi clone mappings.
"_PACKAGE"

globalVariables(".")

defaultCol <- c("gene", "sequence", "name")
userAgent <- "http://steinbaugh.com/worminfo/"
