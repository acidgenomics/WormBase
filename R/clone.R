#' Feeding RNAi Library clone matching.
#'
#' @import dplyr
#'
#' @param id Clone identifier.
#' @param format Identifier format - \code{clone} (e.g. GHR-11010@G06), \code{gene} (e.g. sbp-1), \code{genePair} (e.g. Y47D3B.7), \code{sequence} (e.g. Y47D3B.7))
#' @param library Library type ("orfeome" or "ahringer").
#' @param wells Library plate format (96, 384).
#'
#' @return tibble with \code{gene()} metadata.
#'
#' @export
#'
#' @examples
#' clone("GHR-11010@G06", library = "orfeome")
#' clone("086-B01", library = "ahringer", wells = 96)
#' clone("III-006-C01", library = "ahringer", wells = 384)
#' clone("Y47D3B.7", format = "genePair")
#' clone("skn-1", format = "name")
clone <- function(id = NULL,
                  format = "clone",
                  library = "orfeome",
                  wells = NULL) {
    data <- worminfo::cloneData
    data <- left_join(data, gene(data$gene, format = "gene"), by = "gene")

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
        if (library == "ahringer" && wells == 96) {
            # Chromosome number isn't necessary
            id <- gsub("^([IVX]+)-", "", id)
        }
        if (format == "clone") {
            # Match beginning of line or after comma:
            grepl <- paste0("^", id, "|,\\s", id)
            if (library == "ahringer") {
                if (wells == 96) {
                    #! data <- filter(data, ahringer96 %in% id)
                    match <- filter(data, grepl(grepl, ahringer96))
                } else if (wells == 384) {
                    #! data <- filter(data, ahringer384 %in% id)
                    match <- filter(data, grepl(grepl, ahringer384))
                }
            } else if (library == "orfeome") {
                #! data <- filter(data, orfeome96 %in% id)
                match <- filter(data, grepl(grepl, orfeome96))
            }
        } else if (format == "gene") {
            match <- filter(data, gene %in% id)
        } else if (format == "genePair") {
            match <- filter(data, genePair %in% id)
        } else if (format == "name") {
            match <- filter(data, name %in% id)
        } else if (format == "sequence") {
            match <- filter(data, sequence %in% id)
        }
        return(match)
    } else {
        return(data)
    }
}
