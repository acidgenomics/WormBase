## FIXME Need to update NAMESPACE to use AcidGenerics.



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

#' @importFrom AcidBase pasteURL
#' @importFrom AcidCLI abort alert
#' @importFrom goalie allAreMatchingRegex assert bapply hasLength
#' hasNoDuplicates isAFile isAURL isCharacter isFlag isMatchingRegex isString
#' isSubset
#' @importFrom IRanges CharacterList DataFrameList
#' @importFrom S4Vectors DataFrame List
#' @importFrom httr content content_type_json GET user_agent
#' @importFrom methods as is
#' @importFrom pipette cacheURL transmit
#' @importFrom utils packageName untar
NULL



## FIXME Consider reworking with stringi

#' @importFrom stringr str_extract str_extract_all str_match str_match_all
#' str_sub
NULL
