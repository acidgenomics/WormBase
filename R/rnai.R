#' RNAi clone matching.
#'
#' @import dplyr
#' @import parallel
#' @import seqcloudr
#'
#' @param identifier Identifier.
#' @param format Identifier format.
#' @param library Library type.
#'
#' @return tibble.
#'
#' @export
#'
#' @examples
#' rnai("GHR-11049@F12", library = "orfeome")
#' rnai("IV-2N18", library = "ahringer384")
#' rnai("99G09", library = "ahringer96")
#' rnai("99G09", library = "ahringer96Historical")
#' rnai("tf_all-3C06", library = "cherrypick")
#' rnai("MV_SV:mv_T19E7.2", format = "historical")
#' rnai("WBRNAi00009186", format = "rnai")
#' rnai("T19E7.2", format = "sequence")
#' rnai("skn-1", format = "name")
rnai <- function(identifier = NULL,
                  format = "clone",
                  library = "orfeome96") {
    if (!is.null(identifier)) {
        identifier <- seqcloudr::sortUnique(identifier)
        list <- parallel::mclapply(seq_along(identifier), function(a) {
            id <- identifier[a]
            if (format == "clone") {
                if (library != "ahringer384") {
                    # Prefix (chromosome) is only needed for \code{ahringer384}:
                    id <- gsub("^[A-Za-z0-9]+-", "", id)
                }
                id <- id %>%
                    gsub("-|@", "", .) %>%
                    gsub("^[0]+", "", .) %>%
                    gsub("([A-Z]{1})[0]+", "\\1", .)
            }
            # Match beginning of line or after comma:
            grepl <- paste0(
                # Unique:
                "^", id, "$",
                "|",
                # Beginning of list:
                "^", id, ",",
                "|",
                # Middle of list:
                "\\s", id, ",",
                "|",
                # End of list:
                "\\s", id, "$")
            if (format == "clone") {
                if (library == "ahringer384") {
                    match <- dplyr::filter(rnaiData, grepl(grepl, ahringer384))
                } else if (library == "ahringer96") {
                    match <- dplyr::filter(rnaiData, grepl(grepl, ahringer96))
                } else if (library == "ahringer96Historical") {
                    match <- dplyr::filter(rnaiData, grepl(grepl, ahringer96Historical))
                } else if (library == "cherrypick") {
                    match <- dplyr::filter(rnaiData, grepl(grepl, cherrypick))
                } else if (grepl("^(orfeome|vidal)", library)) {
                    match <- dplyr::filter(rnaiData, grepl(grepl, orfeome96))
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
                match <- dplyr::filter(rnaiData, grepl(grepl, gene))
            } else if (format == "historical") {
                match <- dplyr::filter(rnaiData, grepl(grepl, historical))
            } else if (format == "name") {
                match <- dplyr::filter(rnaiData, grepl(grepl, name))
            } else if (format == "sequence") {
                match <- dplyr::filter(rnaiData, grepl(grepl, sequence))
            }
        })
        dplyr::bind_rows(list)
    } else {
        return(data)
    }
}
