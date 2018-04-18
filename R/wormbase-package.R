#' wormbase
#'
#' *C. elegans* genome annotations from WormBase.
#'
#' @keywords internal
#'
#' @importFrom basejump camel fixNA initializeDirectory removeNA toStringUnique
#'   transmit
#' @importFrom dplyr arrange bind_rows everything group_by mutate rename select
#' @importFrom httr content content_type_json GET user_agent
#' @importFrom magrittr set_colnames set_rownames
#' @importFrom parallel mclapply
#' @importFrom pbapply pblapply
#' @importFrom readr read_csv read_delim read_file read_lines read_tsv
#' @importFrom rlang !! !!! .data abort inform warn sym syms
#' @importFrom stats aggregate formula
#' @importFrom stringr str_extract str_extract_all str_match str_match_all
#'   str_sub
#' @importFrom tibble as_tibble
#' @importFrom utils globalVariables untar
#'
#' @importFrom assertive assert_all_are_matching_regex
#' @importFrom assertive assert_has_no_duplicates
#' @importFrom assertive assert_is_a_string
#' @importFrom assertive assert_is_character
#' @importFrom assertive assert_is_of_length
#' @importFrom assertive is_a_string
#'
#' @importFrom basejump assertIsAStringOrNULL
"_PACKAGE"
