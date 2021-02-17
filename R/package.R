#' WormBase
#'
#' Fetch *Caenorhabditis elegans* genome annotations from WormBase.
#'
#' @keywords internal
#'
#' @importFrom BiocParallel bplapply bpparam
#' @importFrom basejump DataFrame DataFrameList aggregate alert camelCase
#'   formula head import makeNames pasteURL rbindlist removeNA sanitizeNA split
#'   t tail transmit unlist unsplit untar
#' @importFrom goalie allAreMatchingRegex assert bapply hasLength
#'   hasNoDuplicates isCharacter isFlag isString
#' @importFrom httr content content_type_json GET user_agent
#' @importFrom methods as
#' @importFrom stringr str_extract str_extract_all str_match str_match_all
#'   str_sub
"_PACKAGE"
