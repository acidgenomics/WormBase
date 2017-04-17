#' EggNOG annotations
#'
#' @author Michael Steinbaugh
#'
#' @param identifier EggNOG identifier
#'
#' @return tibble
#' @export
eggnog <- function(identifier) {
    identifier <- uniqueIdentifier(identifier)
    annotation <- get("annotation",
                      envir = asNamespace("worminfo"))$eggnog$annotation
    annotationMatch <- annotation %>%
        .[.$eggnog %in% identifier, ] %>%
        # Hide "S = Function unknown" matches
        .[.$cogFunctionalCategory != "S", ]
    if (nrow(annotationMatch)) {
        category <- get("annotation",
                        envir = asNamespace("worminfo"))$eggnog$category
        categoryMatch <- lapply(seq_along(
            annotationMatch$cogFunctionalCategory), function(a) {
            letter <- annotationMatch$cogFunctionalCategory[a] %>%
                strsplit("") %>%
                unlist %>%
                sort %>%
                unique
            category %>% .[.$cogFunctionalCategory %in% letter, ] %>%
                toStringSummarize
        }) %>% bind_rows %>% distinct
        categoryMatch$cogFunctionalCategory <-
            gsub(", ", "", categoryMatch$cogFunctionalCategory)
        left_join(annotationMatch, categoryMatch, by = "cogFunctionalCategory")
    }
}
