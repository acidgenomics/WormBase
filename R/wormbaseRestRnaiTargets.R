#' WormBase RESTful RNAi targets query.
#'
#' @import dplyr
#' @import stats
#' @import stringr
#'
#' @param rnai WormBase RNAi identifier vector.
#'
#' @return tibble.
#' @export
#'
#' @examples
#' wormbaseRestRnaiTargets("WBRNAi00031683")
wormbaseRestRnaiTargets <- function(rnai) {
    rnai <- rnai %>%
        stats::na.omit(.) %>%
        unique(.) %>%
        sort(.)
    list <- lapply(seq_along(rnai), function(a) {
        data <- worminfo::wormbaseRest(rnai[a], class = "rnai", instance = "targets") %>%
            .[["targets"]] %>%
            .[["data"]]
        if (length(data)) {
            list <- lapply(seq_along(data), function(b) {
                type <- data[[b]]$target_type %>%
                    tolower %>%
                    stringr::str_replace(., " target", "")
                id <- data[[b]]$gene$id
                list(type = type, id = id)
            })
            tbl <- dplyr::bind_rows(list) %>%
                dplyr::filter(grepl("WBGene", id)) %>%
                dplyr::group_by(type) %>%
                dplyr::summarize(id = toString(sort(unique(id))))
            primary <- tbl %>%
                dplyr::filter(type == "primary") %>%
                dplyr::select(id) %>%
                as.character(.)
            if (primary == "character(0)") {
                primary <- NA
            }
            secondary <- tbl %>%
                dplyr::filter(type == "secondary") %>%
                dplyr::select(id) %>%
                as.character(.)
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
