#' RNAi clone matching
#'
#' @import dplyr
#' @import parallel
#'
#' @param identifier Identifier
#' @param format Identifier format (\code{gene}, \code{historical}, \code{name},
#'   \code{rnai} or \code{sequence})
#' @param library Library type (\code{ahringer96}, \code{ahringer96Historical},
#'   \code{ahringer384}, \code{cherrypick} or \code{orfeome})
#'
#' @return tibble
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
rnai <- function(identifier,
                 format = "clone",
                 library = "orfeome96") {
    # Download RNAi source data:
    if (!exists("rnaiData", envir = parent.frame())) {
        assign("rnaiData", tempfile(), envir = parent.frame())
        utils::download.file(rnaiDataFile, get("rnaiData", envir = parent.frame()))
        load(get("rnaiData", envir = parent.frame()))
    }
    data <- get("rnaiData", envir = parent.frame())
    if (!missing(identifier)) {
        identifier <- sort(unique(identifier))
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
                    data <- dplyr::filter(data, grepl(grepl, ahringer384))
                } else if (library == "ahringer96") {
                    data <- dplyr::filter(data, grepl(grepl, ahringer96))
                } else if (library == "ahringer96Historical") {
                    data <- dplyr::filter(data, grepl(grepl, ahringer96Historical))
                } else if (library == "cherrypick") {
                    data <- dplyr::filter(data, grepl(grepl, cherrypick))
                } else if (grepl("^(orfeome|vidal)(96)?$", library)) {
                    data <- dplyr::filter(data, grepl(grepl, orfeome96))
                } else {
                    stop("Invalid library.")
                }
                # Add the clone identifier back to data:
                if (nrow(data)) {
                    data <- data %>%
                        dplyr::mutate(clone = identifier[a])
                }
            } else if (format == "gene") {
                data <- dplyr::filter(data, grepl(grepl, gene))
            } else if (format == "historical") {
                data <- dplyr::filter(data, grepl(grepl, historical))
            } else if (format == "name") {
                data <- dplyr::filter(data, grepl(grepl, name))
            } else if (format == "rnai") {
                data <- dplyr::filter(data, grepl(grepl, rnai))
            } else if (format == "sequence") {
                data <- dplyr::filter(data, grepl(grepl, sequence))
            } else {
                stop("Invalid format.")
            }
        })
        data <- dplyr::bind_rows(list)
        # Fix clone identifier columns:
        if (format == "clone") {
            # Clone location columns are unnecessary here:
            data <- data %>%
                dplyr::select(-c(ahringer384,
                                 ahringer96,
                                 ahringer96Historical,
                                 cherrypick,
                                 orfeome96))
        } else {
            # Clean up the appearance of clone locations:
            data <- data %>%
                dplyr::mutate(
                    # Add dash separator:
                    ahringer384 = gsub("(^|,\\s)([IVX]+)(\\d+)", "\\1\\2-\\3", ahringer384),
                    cherrypick = gsub("(^|,\\s)([a-z_]+)", "\\1\\2-", cherrypick),
                    # Pad well numbers:
                    ahringer384 = gsub("(\\D)(\\d)(,|$)", "\\10\\2\\3", ahringer384),
                    ahringer96 = gsub("(\\D)(\\d)(,|$)", "\\10\\2\\3", ahringer96),
                    ahringer96Historical = gsub("(\\D)(\\d)(,|$)", "\\10\\2\\3", ahringer96Historical),
                    cherrypick = gsub("(\\D)(\\d)(,|$)", "\\10\\2\\3", cherrypick),
                    orfeome96 = gsub("(\\D)(\\d)(,|$)", "\\10\\2\\3", orfeome96)
                )
        }
    } else {
        stop("An identifier is required.")
    }
    return(data)
}
