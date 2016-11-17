#' RNAi clone mapping
#'
#' @import dplyr
#' @importFrom parallel mclapply
#' @importFrom stats na.omit
#'
#' @param identifier Identifier
#' @param format Identifier format (\code{gene}, \code{historical}, \code{name},
#'   \code{oligo}, \code{rnai} or \code{sequence})
#' @param library Library type (\code{ahringer96}, \code{ahringer384}, 
#'   \code{cherrypick} or \code{orfeome96})
#'
#' @return tibble
#'
#' @export
#'
#' @examples
#' rnai("sbp-1", format = "name")
#' rnai("WBGene00004735", format = "gene")
#' rnai("Y47D3B.7", format = "sequence")
#' rnai("JA:Y47D3B.7", format = "historical")
#' rnai("sjj_Y47D3B.7", format = "oligo")
#' rnai("WBRNAi00009345", format = "rnai")
#' rnai("III-6C01", library = "ahringer384")
#' rnai("86B01", library = "ahringer96")
#' rnai("GHR-11010@G06", library = "orfeome96")
#' rnai("tf_all-1E01", library = "cherrypick")
rnai <- function(identifier,
                 format = "clone",
                 library = "orfeome96") {
    if (missing(identifier)) {
        stop("An identifier is required.")
    } else if (!is.character(identifier)) {
        stop("Identifier must be a character vector.")
    }
    source <- get("rnaiSource", envir = asNamespace("worminfo"))
    identifier <- sort(unique(stats::na.omit(identifier)))
    list <- parallel::mclapply(seq_along(identifier), function(a) {
        id <- identifier[a]
        if (format == "clone") {
            # Roman chromosome prefix is needed for \code{ahringer384}.
            # Otherwise, it's okay to gsub the clone prefix.
            if (!grepl("^[IVX]+", id) && library != "cherrypick") {
                id <- gsub("^[A-Za-z]+(96|384)?-", "", id)
            }
            # Remove padded zeroes:
            id <- gsub("(^|-)[0]+", "", id)
            id <- gsub("([A-Z]{1})[0]+(\\d)$", "\\1\\2", id)
            # Strip separators:
            id <- gsub("-|@", "", id)
        
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
                data <- source[grepl(grepl, source[[library]]), ]
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
                               "oligo",
                               "rnai",
                               "sequence")))) {
            data <- source[grepl(grepl, source[[format]]), ]
        } else {
            stop("Invalid format.")
        }
        return(data)
    })
    data <- dplyr::bind_rows(list)
    # Hide cherrypick identifiers from user:
    data$ahringer96Historical <- NULL
    data$cherrypick <- NULL
    # Hide unnecessary clone library identifiers:
    if (format == "clone") {
        # Clone location columns are unnecessary here:
        data <- data[, !(names(data) %in% c("ahringer384",
                                            "ahringer96",
                                            "cherrypick",
                                            "orfeome96"))]
    } else {
        # Chromosome separator:
        data$ahringer384 <- gsub("(^|,\\s)([IVX]+)(\\d+)", "\\1\\2-\\3", data$ahringer384)
        # Pad well numbers:
        data$ahringer384 <- gsub("(\\D)(\\d)(,|$)", "\\10\\2\\3", data$ahringer384)
        data$ahringer96 <- gsub("(\\D)(\\d)(,|$)", "\\10\\2\\3", data$ahringer96)
        data$orfeome96 <- gsub("(\\D)(\\d)(,|$)", "\\10\\2\\3", data$orfeome96)
        # Plate separator:
        data$ahringer384 <- gsub("(\\D\\d{2})(,|$)", "-\\1\\2", data$ahringer384)
        data$ahringer96 <- gsub("(\\D\\d{2})(,|$)", "-\\1\\2", data$ahringer96)
        data$orfeome96 <- gsub("(\\D\\d{2})(,|$)", "-\\1\\2", data$orfeome96)
    }
    return(data)
}
