#' WormBase
#'
#' Fetch *Caenorhabditis elegans* genome annotations from WormBase.
#'
#' @keywords internal
#'
"_PACKAGE"



## S4 generics and methods =====================================================

#' @importFrom AcidGenerics camelCase makeNames rbindToDataFrame removeNa
#' sanitizeNa
#' @importFrom BiocGenerics do.call lapply t unlist unsplit
#' @importFrom S4Vectors aggregate head split tail
#' @importFrom pipette import
#'
#' @importMethodsFrom AcidPlyr rbindToDataFrame
#' @importMethodsFrom pipette import removeNa sanitizeNa
#' @importMethodsFrom syntactic camelCase makeNames
NULL


## S3 generics =================================================================

#' @importFrom stats formula
NULL



## Standard functions ==========================================================

#' @importFrom AcidBase pasteUrl strExtract strMatch strMatchAll strSplit
#' tempdir2 unlink2
#' @importFrom AcidCLI abort alert
#' @importFrom goalie allAreMatchingRegex assert bapply hasLength
#' hasNoDuplicates isAFile isAUrl isCharacter isFlag isMatchingRegex isString
#' isSubset
#' @importFrom IRanges CharacterList DataFrameList
#' @importFrom S4Vectors DataFrame List
#' @importFrom methods as is
#' @importFrom parallel mclapply
#' @importFrom pipette cacheUrl getJson transmit
#' @importFrom utils URLencode packageName untar
NULL
