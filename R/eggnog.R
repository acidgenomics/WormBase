#' EggNOG Annotations
#'
#' @keywords internal
#'
#' @importFrom basejump collapseToString
#' @importFrom dplyr bind_rows distinct left_join
#'
#' @param identifier EggNOG identifier.
#'
#' @return [tibble].
#' @export
#'
#' @examples
#' # daf-2
#' eggnog(c("KOG4258", "COG0515")) %>% glimpse()
#'
#' # Multiple EGGNOG letters
#' eggnog("ENOG410IU5G") %>% glimpse()
eggnog <- function(identifier) {
    identifier <- .uniqueIdentifier(identifier)
    annotation <- worminfo::worminfo %>%
        .[["eggnog"]] %>%
        .[["annotation"]]
    annotationMatch <- annotation %>%
        .[.[["eggnog"]] %in% identifier, ] %>%
        # Hide "S = Function unknown" matches
        .[.[["cogFunctionalCategory"]] != "S", ]
    if (!nrow(annotationMatch)) {
        return(NULL)
    }

    # This step is needed to handle multiple EGGNOG category letters (e.g. AK)
    category <- worminfo::worminfo[["eggnog"]][["category"]]
    categoryMatch <- lapply(seq_along(
        annotationMatch[["cogFunctionalCategory"]]), function(a) {
            letter <- annotationMatch[["cogFunctionalCategory"]][[a]] %>%
                strsplit("") %>%
                unlist() %>%
                sort() %>%
                unique()
            category %>%
                .[.[["letter"]] %in% letter, ] %>%
                collapseToString(sort = TRUE, unique = TRUE) %>%
                mutate(letter = gsub(x = .data[["letter"]], ", ", ""))
        }) %>%
        bind_rows() %>%
        distinct() %>%
        rename(cogFunctionalCategory = .data[["letter"]],
               cogFunctionalDescription = .data[["description"]])
    left_join(
        annotationMatch,
        categoryMatch,
        by = "cogFunctionalCategory")
}
