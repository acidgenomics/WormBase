# Example: skn-1, WBGene00004804, P34707 (UniProt)
# ENOG410ZGMS (LUCA)
# KOG3863 (Eukaryota)

#' EggNOG annotations
#'
#' @importFrom dplyr left_join rename_ select_
#'
#' @param query EggNOG identifier
#'
#' @return tibble
#' @export
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
                                 "consensusFunctionalDescription")) %>%
        dplyr::rename_(.dots = c("eggnog" = "groupName"))
}
