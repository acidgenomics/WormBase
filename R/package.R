#' WormBase
#'
#' Fetch *Caenorhabditis elegans* genome annotations from WormBase.
#'
#' @keywords internal
#'
#' @importFrom basejump CharacterList DataFrame DataFrameList List aggregate
#'   alert cacheURL camelCase do.call formula head import lapply makeNames
#'   packageName pasteURL rbindToDataFrame removeNA sanitizeNA split str_extract
#'   str_extract_all str_match str_match_all str_sub t tail transmit unlist
#'   unsplit untar
#' @importFrom goalie allAreMatchingRegex assert bapply hasLength
#'   hasNoDuplicates isAFile isAURL isCharacter isFlag isMatchingRegex isString
#'   isSubset
#' @importFrom httr content content_type_json GET user_agent
#' @importFrom methods as is
"_PACKAGE"



#' Parameters
#'
#' @name params
#' @keywords internal
#'
#' @param file `character(1)`.
#'   Annotation file name.
#' @param genes `character`.
#'   Gene identifiers (e.g. WBGene00004804).
#' @param release `character(1)` or `NULL`.
#'   WormBase release. If `NULL` (recommended), defaults to current production
#'   release release available on the WormBase website. Legacy releases can be
#'   specified as a character string (e.g. "WS267").
NULL
