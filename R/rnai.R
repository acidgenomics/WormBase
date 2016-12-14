#' RNAi clone mapping
#'
#' @import dplyr
#' @importFrom parallel mclapply
#' @importFrom stats na.omit
#'
#' @param query Identifier query
#' @param format Identifier format (\code{gene}, \code{name}, or \code{sequence})
#' @param library Library type (\code{ahringer96}, \code{ahringer384}, or \code{orfeome96})
#'
#' @return tibble
#'
#' @export
#'
#' @examples
#' rnai("sbp-1", format = "name")
#' rnai("WBGene00004735", format = "gene")
#' rnai("Y47D3B.7", format = "sequence")
#' rnai("GHR-11010@G06", library = "orfeome96")
#' rnai("III-6C01", library = "ahringer384")
#' rnai("86B01", library = "ahringer96")
rnai <- function(query,
                 format = "clone",
                 library = "orfeome96") {
    if (missing(query)) {
        stop("An identifier is required.")
    } else if (!is.character(query)) {
        stop("Identifier must be a character vector.")
    }
    annotation <- get("rnaiAnnotation", envir = asNamespace("worminfo"))
    query <- query %>% stats::na.omit(.) %>% unique %>% sort
    list <- parallel::mclapply(seq_along(query), function(a) {
        identifier <- query[a]
        if (format == "clone") {
            if (!any(grepl(library, c("ahringer384",
                                      "ahringer96",
                                      "orfeome96")))) {
                stop("Invalid library.")
            }
            # Roman chromosome prefix is needed for \code{ahringer384}:
            if (!grepl("^[IVX]+", identifier)) {
                identifier <- gsub("^[A-Za-z]+(96|384)?-", "", identifier)
            }
            # Remove padded zeroes:
            identifier <- gsub("(^|-)[0]+", "", identifier)
            identifier <- gsub("([A-Z]{1})[0]+(\\d)$", "\\1\\2", identifier)
            # Strip separators:
            identifier <- gsub("-|@", "", identifier)
            # Match beginning of line or after comma:
            grepl <- paste0(
                # Unique:
                "^", identifier, "$",
                "|",
                # Beginning of list:
                "^", identifier, ",",
                "|",
                # Middle of list:
                "\\s", identifier, ",",
                "|",
                # End of list:
                "\\s", identifier, "$")
            data <- annotation %>%
                .[grepl(grepl, .[[library]]), "gene"]
            if (nrow(data)) {
                # Add the clone identifier back:
                data$clone <- query[a]
            }
        } else if (any(grepl(format, simpleCol))) {
            if (format == "sequence") {
                # Strip out isoform information:
                identifier <- gsub("^([A-Z0-9]+)\\.([0-9]+)[a-z]$", "\\1.\\2", identifier)
            }
            # Query `gene()` function and map to gene identifier:
            data <- gene(identifier, format = format, select = simpleCol)
            if (nrow(data)) {
                data <- data %>%
                    dplyr::left_join(annotation, by = "gene")
                # Make the clone mappings human readable:
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
                if (format == "sequence") {
                    # Add the original sequence query back:
                    data$sequence <- identifier
                }
            }
        } else {
            stop("Invalid format.")
        }
        return(data)
    })
    dplyr::bind_rows(list)
}
