#' WormBase RESTful RNAi targets query.
#' @import dplyr
#' @import stringr
#' @param rnai WormBase RNAi identifier vector.
#' @return tibble.
#' @examples
#' wormbaseRestRnaiTargets("WBRNAi00031683")
#' @export
wormbaseRestRnaiTargets <- function(rnai) {
    rnai <- sort(rnai) %>% unique %>% stats::na.omit(.)
    list <- lapply(seq_along(rnai), function(a) {
        data <- wormbaseRest(rnai[a], class = "rnai", instance = "targets") %>%
            .[["targets"]] %>% .[["data"]]
        if (length(data)) {
            list <- lapply(seq_along(data), function(b) {
                type <- data[[b]]$target_type %>%
                    tolower %>%
                    str_replace(" target", "")
                id <- data[[b]]$gene$id
                list(type = type, id = id)
            })
            tbl <- bind_rows(list) %>%
                filter(grepl("WBGene", id)) %>%
                group_by(type) %>%
                summarize(id = paste(sort(unique(id)), collapse = ", "))
            primary <- filter(tbl, type == "primary") %>%
                select(id) %>%
                as.character
            if (primary == "character(0)") {
                primary <- NA
            }
            secondary <- filter(tbl, type == "secondary") %>%
                select(id) %>%
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
    bind_rows(list)
}
