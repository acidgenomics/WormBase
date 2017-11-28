#' EggNOG Annotations
#'
#' @importFrom basejump collapseToString
#' @importFrom dplyr bind_rows distinct left_join
#'
#' @param identifier EggNOG identifier.
#'
#' @return [tibble].
#' @export
eggnog <- function(identifier) {
    identifier <- .uniqueIdentifier(identifier)
    annotation <- get("worminfo", envir = asNamespace("worminfo")) %>%
        .[["eggnog"]] %>%
        .[["annotation"]]
    annotationMatch <- annotation %>%
        .[.[["eggnog"]] %in% identifier, ] %>%
        # Hide "S = Function unknown" matches
        .[.[["cogFunctionalCategory"]] != "S", ]
    if (nrow(annotationMatch)) {
        category <-
            get("annotations",
                envir = asNamespace("worminfo"))[["eggnog"]][["category"]]
        categoryMatch <- lapply(seq_along(
            annotationMatch[["cogFunctionalCategory"]]), function(a) {
            letter <- annotationMatch[["cogFunctionalCategory"]][a] %>%
                strsplit("") %>%
                unlist() %>%
                sort() %>%
                unique()
            category %>%
                .[.[["cogFunctionalCategory"]] %in% letter, ] %>%
                collapseToString()
        }) %>%
            bind_rows() %>%
            distinct()
        categoryMatch[["cogFunctionalCategory"]] <-
            gsub(pattern = ", ",
                 replacement = "",
                 x = categoryMatch[["cogFunctionalCategory"]])
        annotationMatch <- left_join(
            annotationMatch,
            categoryMatch,
            by = "cogFunctionalCategory")
    }
    annotationMatch
}
