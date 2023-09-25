#' WormBase
#'
#' Fetch *Caenorhabditis elegans* genome annotations from WormBase.
#'
#' @keywords internal
#'
"_PACKAGE"



## S4 generics and methods =====================================================

#' @importFrom AcidGenerics camelCase makeNames rbindToDataFrame removeNA
#' sanitizeNA
#' @importFrom BiocGenerics do.call lapply t unlist unsplit
#' @importFrom S4Vectors aggregate head split tail
#' @importFrom pipette import
#'
#' @importMethodsFrom AcidPlyr rbindToDataFrame
#' @importMethodsFrom pipette import removeNA sanitizeNA
#' @importMethodsFrom syntactic camelCase makeNames
NULL


## S3 generics =================================================================

#' @importFrom stats formula
NULL



## Standard functions ==========================================================

#' @importFrom AcidBase pasteURL tempdir2 unlink2
#' @importFrom AcidCLI abort alert
#' @importFrom goalie allAreMatchingRegex assert bapply hasLength
#' hasNoDuplicates isAFile isAURL isCharacter isFlag isMatchingRegex isString
#' isSubset
#' @importFrom IRanges CharacterList DataFrameList
#' @importFrom S4Vectors DataFrame List
#' @importFrom methods as is
#' @importFrom pipette cacheURL getJSON transmit
#' @importFrom utils URLencode packageName untar
NULL
