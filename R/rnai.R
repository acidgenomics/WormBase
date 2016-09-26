#' RNAi clone matching
#'
#' @importFrom dplyr bind_rows
#' @importFrom parallel mclapply
#'
#' @param identifier Identifier
#' @param format Identifier format (\code{gene}, \code{historical}, \code{name},
#'   \code{rnai} or \code{sequence})
#' @param library Library type (\code{ahringer96}, \code{ahringer384},
#'   \code{cherrypick} or \code{orfeome96})
#'
#' @return tibble
#'
#' @export
#'
#' @examples
#' rnai("IV-2N18", library = "ahringer384")
#' rnai("99G09", library = "ahringer96")
#' rnai("tf_all-3C06", library = "cherrypick")
#' rnai("GHR-11049@F12", library = "orfeome96")
#' rnai("WBGene00004804", format = "gene")
#' rnai("JA:T19E7.2", format = "historical")
#' rnai("skn-1", format = "name")
#' rnai("WBRNAi00009186", format = "rnai")
#' rnai("T19E7.2", format = "sequence")
rnai <- function(identifier,
                 format = "clone",
                 library = "orfeome96") {
    data <- get("rnaiData", envir = asNamespace("worminfo"))

    # Don't expose ahringer96Historical values to the user:
    data$ahringer96Historical <- NULL

    if (!missing(identifier)) {
        if (!is.character(identifier)) {
            stop("Identifier must be a character vector.")
        }
        identifier <- sort(unique(identifier))
        list <- parallel::mclapply(seq_along(identifier), function(a) {
            id <- identifier[a]
            if (format == "clone") {
                if (library != "ahringer384") {
                    # Prefix (chromosome) is only needed for \code{ahringer384}:
                    id <- gsub("^[A-Za-z0-9]+-", "", id)
                }
                id <- gsub("-|@", "", id)
                id <- gsub("^[0]+", "", id)
                id <- gsub("([A-Z]{1})[0]+", "\\1", id)
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
                if (any(grepl(library,
                              c("ahringer384",
                                "ahringer96",
                                "cherrypick",
                                "orfeome96")))) {
                    data <- data[grepl(grepl, data[[library]]), ]
                } else {
                    stop("Invalid library.")
                }
                # Add the clone identifier back to data:
                if (nrow(data)) {
                    data$clone <- identifier[a]
                }
            } else if (any(grepl(format,
                                 c("gene",
                                   "historical",
                                   "name",
                                   "rnai",
                                   "sequence")))) {
                data <- data[grepl(grepl, data[[format]]), ]
            } else {
                stop("Invalid format.")
            }
            return(data)
        })
        data <- dplyr::bind_rows(list)
        # Fix clone identifier columns:
        if (format == "clone") {
            # Clone location columns are unnecessary here:
            data <- data[, !(names(data) %in% c("ahringer384",
                                                "ahringer96",
                                                "cherrypick",
                                                "orfeome96"))]
        } else {
            # Clean up the appearance of clone locations
            # Plate separator:
            data$ahringer384 <- gsub("(^|,\\s)([IVX]+)(\\d+)", "\\1\\2-\\3", data$ahringer384)
            data$cherrypick <- gsub("(^|,\\s)([a-z_]+)", "\\1\\2-", data$cherrypick)
            # Pad well numbers:
            data$ahringer384 <- gsub("(\\D)(\\d)(,|$)", "\\10\\2\\3", data$ahringer384)
            data$ahringer96 <- gsub("(\\D)(\\d)(,|$)", "\\10\\2\\3", data$ahringer96)
            data$cherrypick <- gsub("(\\D)(\\d)(,|$)", "\\10\\2\\3", data$cherrypick)
            data$orfeome96 <- gsub("(\\D)(\\d)(,|$)", "\\10\\2\\3", data$orfeome96)
        }
    } else {
        stop("An identifier is required.")
    }
    return(data)
}
