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
#' rnaiTargets("WBRNAi00000001")
rnaiTargets <- function(rnai) {
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
