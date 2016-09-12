#' Feeding RNAi Library clone matching.
#' @import dplyr
#' @import magrittr
#' @param id Clone identifier.
#' @param library Library type ("orfeome" or "ahringer").
#' @param wells Library plate format (96, 384).
#' @param select Select columns (report, simple).
#' @return tibble with \code{gene()} metadata.
#' @examples
#' clone("11010-G06", library = "orfeome")
#' clone("086-B01", library = "ahringer", wells = 96)
#' clone("III-006-C01", library = "ahringer", wells = 384)
#' @export
clone <- function(id = NULL,
                  library = "orfeome",
                  wells = NULL,
                  select = "simple") {
    if (!is.null(id)) {
        id <- gsub("^(ahringer|GHR|orfeome)(96|384)?-", "", id) %>%
            gsub("@", "-", .) %>%
            # Separator for Ahringer IDs
            gsub("-([0-9]+)([A-Z]+)", "-\\1-\\2", .) %>%
            # Padded zeroes for Ahringer plates
            gsub("^([IVX]+)-([0-9]{1})-", "\\1-00\\2-", .) %>%
            gsub("^([IVX]+)-([0-9]{2})-", "\\1-0\\2-", .) %>%
            # Padded zeroes for wells
            gsub("([A-Z]{1})([0-9]{1})$", "\\10\\2", .)
    }
    if (library == "ahringer") {
        if (!is.null(id)) {
            if (wells == 96) {
                # Chromosome number isn't necessary
                id <- gsub("^([IVX]+)-", "", id)
                data <- dplyr::filter_(cloneData$ahringer, ~ahringer96 %in% id)
            } else if (wells == 384) {
                data <- dplyr::filter_(cloneData$ahringer, ~ahringer384 %in% id)
            }
        }
    } else if (library == "orfeome") {
        if (!is.null(id)) {
            data <- dplyr::filter_(cloneData$orfeome, ~orfeome96 %in% id)
        }
    }
    dplyr::left_join(data, gene(data$geneId, format = "geneId", select = select))
}
