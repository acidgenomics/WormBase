#' EggNOG annotations
#'
#' @export
#' @importFrom dplyr left_join rename_ select_
#' @param identifier EggNOG identifier
#' @return tibble
#'
#' @examples
#' c("ENOG410XPQV", "KOG0289") %>% eggnog
eggnog <- function(identifier) {
    if (missing(identifier)) {
        stop("An identifier is required.")
    } else if (!is.character(identifier)) {
        stop("Identifier must be a character vector.")
    }
    annotation <- get("eggnogAnnotation", envir = asNamespace("worminfo")) %>%
        .[.$groupName %in% identifier,
          c("groupName",
            "consensusFunctionalDescription",
            "cogFunctionalCategory")] %>%
        dplyr::rename_(.dots = c("eggnog" = "groupName"))
    category <- get("eggnogCategory", envir = asNamespace("worminfo"))
    return <- lapply(seq_along(annotation$cogFunctionalCategory), function(a) {
        letter <- annotation$cogFunctionalCategory[a] %>%
            strsplit("") %>%
            unlist %>%
            sort %>%
            unique
        category %>% .[.$cogFunctionalCategory %in% letter, ] %>%
            collapse
    }) %>% dplyr::bind_rows(.)
    return$cogFunctionalCategory <- gsub(", ", "", return$cogFunctionalCategory)
    return(return)
}
