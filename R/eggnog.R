#' EggNOG annotations
#' 
#' @author Michael Steinbaugh
#' @export
#' @importFrom dplyr distinct left_join rename_ select_
#' @keywords internal
#' @param identifier EggNOG identifier
#' @return tibble
eggnog <- function(identifier) {
    identifier <- uniqueIdentifier(identifier)
    annotation <- get("annotation", envir = asNamespace("worminfo"))$eggnog$annotation
    annotationMatch <- annotation %>%
        .[.$eggnog %in% identifier, ] %>%
        # Hide "S = Function unknown" matches:
        .[.$cogFunctionalCategory != "S", ]
    if (nrow(annotationMatch)) {
        category <- get("annotation", envir = asNamespace("worminfo"))$eggnog$category
        categoryMatch <- lapply(seq_along(annotationMatch$cogFunctionalCategory), function(a) {
            letter <- annotationMatch$cogFunctionalCategory[a] %>%
                strsplit("") %>%
                unlist %>%
                sort %>%
                unique
            category %>% .[.$cogFunctionalCategory %in% letter, ] %>%
                toStringSummarize
        }) %>% dplyr::bind_rows(.) %>%
            dplyr::distinct(.)
        categoryMatch$cogFunctionalCategory <- gsub(", ", "", categoryMatch$cogFunctionalCategory)
        dplyr::left_join(annotationMatch, categoryMatch, by = "cogFunctionalCategory")
    }
}
