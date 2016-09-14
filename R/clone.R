#' Feeding RNAi Library clone matching.
#' @import dplyr
#' @param id Clone identifier.
#' @param format Identifier format ("cloneId" or "genePair")
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
                  format = "cloneId",
                  library = "orfeome",
                  wells = NULL,
                  select = "simple") {
    if (!is.null(id)) {
        if (format == "cloneId") {
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
    }
    if (library == "ahringer") {
        if (!is.null(id)) {
            if (format == "cloneId") {
                if (wells == 96) {
                    # Chromosome number isn't necessary
                    id <- gsub("^([IVX]+)-", "", id)
                    data <- filter(worminfo::cloneData$ahringer, ahringer96 %in% id)
                } else if (wells == 384) {
                    data <- filter(worminfo::cloneData$ahringer, ahringer384 %in% id)
                }
            }
            if (format == "genePair") {
                data <- filter(worminfo::cloneData$ahringer, genePair %in% id)
            }
        }
    } else if (library == "orfeome") {
        if (!is.null(id)) {
            if (format == "cloneId") {
                data <- filter(worminfo::cloneData$orfeome, orfeome96 %in% id)
            }
            if (format == "genePair") {
                data <- filter(worminfo::cloneData$orfeome, genePair %in% id)
            }
        }
    }
    left_join(data, gene(data$geneId, format = "geneId", select = select), by = "geneId")
}
