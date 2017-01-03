#' EggNOG annotations
#'
#' @export
#' @importFrom dplyr left_join rename_ select_
#' @param identifier EggNOG identifier
#' @return tibble
#'
#' @examples
#' eggnog(c("ENOG410ZGMS", "KOG3863"))
eggnog <- function(identifier) {
    annotation <- get("eggnogAnnotation", envir = asNamespace("worminfo"))
    category <- get("eggnogCategory", envir = asNamespace("worminfo"))
    identifier <- identifier %>% stats::na.omit(.) %>% unique %>% sort
    annotation <- annotation %>%
        .[.$groupName %in% identifier,
          c("groupName",
            "consensusFunctionalDescription",
            "cogFunctionalCategory")] %>%
        dplyr::rename_(.dots = c("eggnog" = "groupName"))
    category <- category %>%
        .[.$cogFunctionalCategory %in% strsplit(annotation$cogFunctionalCategory, "")[[1]], ] %>%
        collapse
    category$cogFunctionalCategory <- gsub(", ", "", category$cogFunctionalCategory)
    dplyr::left_join(annotation, category, by = "cogFunctionalCategory")
}
