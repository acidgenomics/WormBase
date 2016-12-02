#' WormBase REST API query
#'
#' @import httr
#'
#' @param url URL query to WormBase RESTful API
#'
#' @return JSON content
#' @export
#'
#' @examples
#' rest("field/gene/WBGene00000001/gene_class")
rest <- function(url) {
    httr::GET(paste0("http://api.wormbase.org/rest/", url),
              config = httr::content_type_json(),
              user_agent = httr::user_agent(ua)) %>%
        httr::content(.)
}



#' WormBase RESTful gene external query
#'
#' @import dplyr
#' @import httr
#' @import tibble
#'
#' @param gene Gene identifier
#'
#' @return JSON content tibble
#' @export
#'
#' @examples
#' restGeneExternal("WBGene00000001")
restGeneExternal <- function(gene) {
    gene <- gene %>% unique %>% sort
    list <- lapply(seq_along(gene), function(a) {
        rest <- paste0("widget/gene/", gene[a], "/external_links") %>% rest %>%
            .$fields %>% .$xrefs %>% .$data
        list(gene = gene[a],
             aceview = rest$AceView$gene$ids[[1]],
             ncbi = rest$NCBI$gene$ids[[1]],
             refseqMrna = rest$RefSeq$mRNA$ids[[1]],
             refseqProtein = rest$RefSeq$protein$ids[[1]],
             treefam = rest$TREEFAM$TREEFAM_ID$ids[[1]],
             uniprot = rest$UniProt$UniProtAcc$ids[[1]])
    })
    dplyr::bind_rows(lapply(list, function(a) {
        tibble::as_tibble(Filter(Negate(is.null), a))
    }))
}



#' WormBase RESTful RNAi reagent query
#'
#' @import dplyr
#'
#' @param rnai RNAi
#'
#' @return JSON content tibble
#' @export
#'
#' @examples
#' restRnaiReagent("WBRNAi00000001")
restRnaiReagent <- function(rnai) {
    rnai <- rnai %>% unique %>% sort
    list <- lapply(seq_along(rnai), function(a) {
        rest <- paste0("field/rnai/", rnai[a], "/reagent") %>% rest %>%
            .$reagent %>% .$data %>% .[[1]]
        if (length(rest)) {
            mrc <- rest$mrc_id
            id <- rest$reagent$id
            label <- rest$reagent$label
        } else {
            mrc <- NA
            id <- NA
            label <- NA
        }
        list(rnai = rnai[a],
             mrc = mrc,
             id = id,
             label = label)
    })
    dplyr::bind_rows(list)
}



#' WormBase RESTful RNAi sequence query
#'
#' @import dplyr
#'
#' @param rnai RNAi
#'
#' @return JSON content tibble
#' @export
#'
#' @examples
#' restRnaiSequence("WBRNAi00000001")
restRnaiSequence <- function(rnai) {
    rnai <- rnai %>% unique %>% sort
    list <- lapply(seq_along(rnai), function(a) {
        rest <- paste0("field/rnai/", rnai[a], "/sequence") %>% rest %>%
            .$sequence %>% .$data %>% .[[1]]
        if (length(rest)) {
            oligo <- rest$header
            length <- rest$length
            sequence <- rest$sequence
        } else {
            oligo <- NA
            length <- NA
            sequence <- NA
        }
        list(rnai = rnai[a],
             oligo = oligo,
             length = length,
             sequence = sequence)
    })
    dplyr::bind_rows(list)
}



#' WormBase RESTful RNAi targets query
#'
#' @import dplyr
#' @importFrom stats setNames
#' @importFrom stringr str_replace
#'
#' @param rnai RNAi
#'
#' @return JSON content tibble
#' @export
#'
#' @examples
#' restRnaiTargets("WBRNAi00000001")
restRnaiTargets <- function(rnai) {
    rnai <- rnai %>% unique %>% sort
    list <- lapply(seq_along(rnai), function(a) {
        rest <- paste0("field/rnai/", rnai[a], "/targets") %>% rest %>%
            .$targets %>% .$data
        if (length(rest)) {
            list <- lapply(seq_along(rest), function(b) {
                type <- rest[[b]]$target_type %>%
                    tolower %>%
                    stringr::str_replace(., " target", "")
                id <- rest[[b]]$gene$id
                list(type = type,
                     id = id)
            })
            tbl <- dplyr::bind_rows(list) %>%
                .[grepl("WBGene", .$id), ]
            dots <- list(~toString(unique(id)))
            tbl <- tbl %>%
                dplyr::group_by_(.dots = "type") %>%
                dplyr::summarise_(.dots = stats::setNames(dots, c("id")))
            primary <- tbl[tbl$type == "primary", "id"] %>%
                as.character
            if (primary == "character(0)") {
                primary <- NA
            }
            secondary <- tbl[tbl$type == "secondary", "id"] %>%
                as.character
            if (secondary == "character(0)") {
                secondary <- NA
            }
        } else {
            primary <- NA
            secondary <- NA
        }
        list(rnai = rnai[a],
             targetPrimary = primary,
             targetSecondary = secondary)
    })
    dplyr::bind_rows(list)
}
