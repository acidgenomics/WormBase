#' Feeding RNAi Library clone matching.
#'
#' @import dplyr
#' @import parallel
#' @import stats
#'
#' @param identifier Identifier.
#' @param format Identifier format - \code{clone} (e.g. GHR-11010@G06), \code{gene} (e.g. sbp-1), \code{genePair} (e.g. Y47D3B.7), \code{sequence} (e.g. Y47D3B.7))
#' @param library Library type ("orfeome" or "ahringer").
#' @param wells Library plate format (96, 384).
#'
#' @return tibble with \code{gene()} metadata.
#'
#' @export
#'
#' @examples
#' clone("GHR-11010@G06")
#' clone("086-B01", library = "ahringer", wells = 96)
#' clone("III-006-C01", library = "ahringer", wells = 384)
#' clone("Y47D3B.7", format = "genePair")
#' clone("sbp-1", format = "name")
clone <- function(identifier = NULL,
                  format = "clone",
                  library = "orfeome",
                  wells = NULL) {
    if (!is.null(identifier)) {
        identifier <- identifier %>%
            stats::na.omit(.) %>%
            unique(.) %>%
            sort(.)
        list <- parallel::mclapply(seq_along(identifier), function(a) {
            id <- identifier[a] %>%
                gsub("^(ahringer|GHR|orfeome)(96|384)?-", "", .) %>%
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
                grepl <- paste0("^", id, "|\\s", id)
                if (library == "ahringer") {
                    if (wells == 96) {
                        match <- dplyr::filter(worminfo::cloneData, grepl(grepl, ahringer96))
                    } else if (wells == 384) {
                        match <- dplyr::filter(worminfo::cloneData, grepl(grepl, ahringer384))
                    }
                } else if (library == "orfeome") {
                    match <- dplyr::filter(worminfo::cloneData, grepl(grepl, orfeome96))
                }
                # Add the clone identifier back to match:
                if (nrow(match) == 1) {
                    match <- match %>%
                        dplyr::mutate(clone = identifier[a])
                }
                # Clone location columns are unnecessary here:
                match <- match %>%
                    dplyr::select(-c(ahringer384,
                                     ahringer96,
                                     ahringer96Historical,
                                     cherrypick,
                                     orfeome96))
            } else if (format == "gene") {
                match <- dplyr::filter(worminfo::cloneData, gene %in% id)
            } else if (format == "genePair") {
                match <- dplyr::filter(worminfo::cloneData, genePair %in% id)
            } else if (format == "name") {
                match <- dplyr::filter(worminfo::cloneData, name %in% id)
            } else if (format == "sequence") {
                match <- dplyr::filter(worminfo::cloneData, sequence %in% id)
            }
        })
        dplyr::bind_rows(list)
    } else {
        return(data)
    }
}
