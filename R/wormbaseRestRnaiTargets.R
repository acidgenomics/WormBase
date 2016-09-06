#' WormBase RESTful RNAi targets query
#'
#' @import dplyr
#' @import magrittr
#'
#' @return \code{tibble}
#'
#' @examples
#' wormbaseRestRnaiTargets("WBRNAi00031683")
wormbaseRestRnaiTargets <- function(query) {
    query <- sort(query) %>% unique %>% na.omit
    #! parallel::mclapply
    list <- lapply(seq_along(query), function(a) {
        wbrnai <- query[a]
        data <- wormbaseRest(wbrnai, class = "rnai", instance = "targets") %>%
            .[["targets"]] %>% .[["data"]]
        if (length(data)) {
            list <- lapply(seq_along(data), function(b) {
                type <- data[[b]]$target_type %>%
                    tolower %>%
                    stringr::str_replace(" target", "")
                id <- data[[b]]$gene$id
                c(type, id)
            })
            tbl <- tibble::as_tibble(do.call(rbind, list)) %>%
                set_names(c("type", "id")) %>%
                filter(grepl("WBGene", id)) %>%
                group_by(type) %>%
                summarize(id = paste(sort(unique(id)),collapse = ", "))
            primary <- filter(tbl, type == "primary") %>% select(id) %>% as.character
            if (primary == "character(0)") {
                primary <- NA
            }
            secondary <- filter(tbl, type == "secondary") %>% select(id) %>% as.character
            if (secondary == "character(0)") {
                secondary <- NA
            }
            c(wbrnai, primary, secondary)
        } else {
            c(wbrnai, NA, NA)
        }
    })
    tibble::as_tibble(do.call(rbind, list)) %>%
        set_names(c("wbrnai", "primary", "secondary"))
}
