#' EggNOG annotations
#'
#' @export
#' @importFrom dplyr left_join select_
#' @param query EggNOG identifier
#' @return tibble
#'
#' @examples
#' eggnog(c("ENOG410ZGMS", "KOG3863"))
eggnog <- function(query) {
    annotation <- get("eggnogAnnotation", envir = asNamespace("worminfo"))
    category <- get("eggnogCategory", envir = asNamespace("worminfo"))
    query <- query %>% stats::na.omit(.) %>% unique %>% sort
    annotation %>%
        .[.$groupName %in% query, ] %>%
        dplyr::left_join(category, by = "cogFunctionalCategory") %>%
        dplyr::select_(.dots = c("groupName",
                                 "cogFunctionalCategory",
                                 "cogFunctionalDescription",
                                 "consensusFunctionalDescription"))
}
