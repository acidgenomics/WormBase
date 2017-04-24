#' \code{worminfo} package
#'
#' C. elegans genome annotations and RNAi clone mappings.
#'
#' See the README on \href{https://github.com/steinbaugh.com/worminfo}{GitHub}.
#'
#' @docType package
#' @name bcbioRnaseq
NULL



# Globals ====
globalVariables(".")



# Imports ====
# General ----
#' @import basejump
#' @importFrom parallel mclapply
#' @importFrom pbmcapply pbmclapply
#' @importFrom stats na.omit setNames
#' @importFrom utils download.file globalVariables
NULL

# Databases ----
#' @importFrom biomaRt getBM useEnsembl
#' @importFrom UniProt.ws UniProt.ws

# tidyverse ----
#' @import dplyr
#' @import httr
#' @import rlang
#' @import stringr
#' @importFrom magrittr %>%
#' @importFrom tibble as_tibble tibble
#' @importFrom tidyr nest separate_ unnest
NULL



# Re-exports ====
#' @usage NULL
#' @export
magrittr::`%>%`
