#' EggNOG annotations
#'
#' @param identifier EggNOG identifier.
#'
#' @return Tibble.
#' @export
eggnog <- function(identifier) {
    identifier <- uniqueIdentifier(identifier)
    annotation <- get("annotations",
                      envir = asNamespace("worminfo"))$eggnog$annotation
    annotationMatch <- annotation %>%
        .[.$eggnog %in% identifier, ] %>%
        # Hide "S = Function unknown" matches
        .[.$cogFunctionalCategory != "S", ]
    if (nrow(annotationMatch)) {
        category <- get("annotations",
                        envir = asNamespace("worminfo"))$eggnog$category
        categoryMatch <- lapply(seq_along(
            annotationMatch$cogFunctionalCategory), function(a) {
            letter <- annotationMatch$cogFunctionalCategory[a] %>%
                # [fix]?
                str_split("") %>%
                unlist %>%
                sort %>%
                unique
            category %>%
                .[.$cogFunctionalCategory %in% letter, ] %>%
                summarizeRows
        }) %>% bind_rows %>% distinct
        categoryMatch$cogFunctionalCategory <-
            gsub(", ", "", categoryMatch$cogFunctionalCategory)
        left_join(annotationMatch, categoryMatch, by = "cogFunctionalCategory")
    }
}
