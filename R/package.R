#' WormBase
#'
#' Fetch *Caenorhabditis elegans* genome annotations from WormBase.
#'
#' @keywords internal
#'
#' @importFrom basejump CharacterList DataFrame DataFrameList List aggregate
#'   alert cacheURL camelCase do.call formula head import lapply makeNames
#'   pasteURL rbindlist removeNA sanitizeNA split t tail transmit unlist
#'   unlistToDataFrame unsplit untar
#' @importFrom goalie allAreMatchingRegex assert bapply hasLength
#'   hasNoDuplicates isAFile isAURL isCharacter isFlag isMatchingRegex isString
#'   isSubset
#' @importFrom httr content content_type_json GET user_agent
#' @importFrom methods as
#' @importFrom stringr str_extract str_extract_all str_match str_match_all
#'   str_sub
"_PACKAGE"
