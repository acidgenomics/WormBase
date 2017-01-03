#' RNAi clone mapping
#'
#' @importFrom dplyr bind_rows left_join
#' @importFrom parallel mclapply
#' @importFrom pbmcapply pbmclapply
#' @importFrom stats na.omit
#'
#' @param identifier Identifier
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
rnai <- function(identifier,
                 format = "clone",
                 library = "orfeome96") {
    if (missing(identifier)) {
        stop("An identifier is required.")
    } else if (!is.character(identifier)) {
        stop("Identifier must be a character vector.")
    }
    annotation <- get("rnaiAnnotation", envir = asNamespace("worminfo"))
    identifier <- identifier %>% stats::na.omit(.) %>% unique %>% sort
    if (length(identifier) < 100) {
        lapply <- parallel::mclapply
    } else {
        lapply <- pbmcapply::pbmclapply
    }
    lapply(seq_along(identifier), function(a) {
        well <- identifier[a]
        if (format == "clone") {
            if (!any(grepl(library, c("ahringer384",
                                      "ahringer96",
                                      "orfeome96")))) {
                stop("Invalid library.")
            }
            # Roman chromosome prefix is needed for \code{ahringer384}:
            if (!grepl("^[IVX]+", well)) {
                well <- gsub("^[A-Za-z]+(96|384)?-", "", well)
            }
            # Remove padded zeroes:
            well <- gsub("(^|-)[0]+", "", well)
            well <- gsub("([A-Z]{1})[0]+(\\d)$", "\\1\\2", well)
            # Strip separators:
            well <- gsub("-|@", "", well)
            # Match beginning of line or after comma:
            grepl <- paste0(
                # Unique:
                "^", well, "$",
                "|",
                # Beginning of list:
                "^", well, ",",
                "|",
                # Middle of list:
                "\\s", well, ",",
                "|",
                # End of list:
                "\\s", well, "$")
            data <- annotation %>%
                .[grepl(grepl, .[[library]]), "gene"]
            if (nrow(data)) {
                # Add the user input clone back:
                data$clone <- identifier[a]
            }
        } else if (any(grepl(format, simpleCol))) {
            geneIdentifier <- identifier[a]
            if (format == "sequence") {
                # Strip out isoform information:
                geneIdentifier <- gsub("^([A-Z0-9]+)\\.([0-9]+)[a-z]$", "\\1.\\2", geneIdentifier)
            }
            # Query `gene()` function and map to gene identifier:
            data <- gene(geneIdentifier, format = format, select = simpleCol)
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
                    # Add the user input sequence back:
                    data$sequence <- identifier[a]
                }
            }
        } else {
            stop("Invalid format.")
        }
        return(data)
    }) %>% dplyr::bind_rows(.)
}
