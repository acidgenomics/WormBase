#' EggNOG annotations
#'
#' @export
#' @importFrom dplyr left_join rename_ select_
#' @param identifier EggNOG identifier
#' @return tibble
#'
#' @examples
#' eggnog(c("ENOG410XPQV", "KOG0289"))
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
        dplyr::rename_(.dots = c("eggnog" = "groupName")) %>%
        collapse
    letter <- annotation$cogFunctionalCategory %>%
        gsub(", ", "", .) %>%
        strsplit("") %>%
        unlist %>%
        sort %>%
        unique
    category <- get("eggnogCategory", envir = asNamespace("worminfo")) %>%
        .[.$cogFunctionalCategory %in% letter, ] %>%
        collapse
    dplyr::left_join(annotation, category, by = "cogFunctionalCategory")
}
