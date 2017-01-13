#' RNAi clone mapping
#'
#' @export
#' @importFrom dplyr bind_rows left_join
#' @importFrom parallel mclapply
#' @importFrom stats na.omit
#' @param identifier Identifier
#' @param format Identifier format (\code{clone}, \code{gene}, \code{genePair},
#'   \code{name}, or \code{sequence})
#' @return tibble
#'
#' @examples
#' rnai("ahringer384-III-6-C01")
#' rnai("ahringer96-86-B01")
#' rnai("GHR-11010@G06")
#' rnai("orfeome96-11010-G06")
#' rnai("sbp-1", format = "name")
#' rnai("WBGene00004735", format = "gene")
#' rnai("Y47D3B.7", format = "sequence")
#' rnai("Y53H1C.b", format = "genePair")
rnai <- function(identifier, format = "clone") {
    identifier <- uniqueIdentifier(identifier)
    grep <- identifier
    annotation <- get("annotation", envir = asNamespace("worminfo"))$rnai
    if (!any(grepl(format, names(annotation)))) {
        stop("Invalid format.")
    }
    if (format == "clone") {
        grep <- grep %>%
            # Strip prefixes:
            gsub("^GHR", "", .) %>%
            gsub("^([a-z]+)(96|384)", "", .) %>%
            # Strip separators:
            gsub("-|@", "", .) %>%
            # Strip padded zeroes:
            gsub("(^|-)[0]+", "", .) %>%
            gsub("([A-Z]{1})[0]+(\\d)$", "\\1\\2", .)
    } else if (format == "sequence") {
        grep <- removeIsoform(grep)
    }
    # Now create the grep string:
    grep <- grep %>% grepString
    return <- parallel::mclapply(seq_along(grep), function(a) {
        return <- annotation %>% .[grepl(grep[a], .[[format]]), ]
        if (nrow(return)) {
            if (format != "clone") {
                # Sort the clones and make human readable:
                return$clone <- return$clone %>%
                    strsplit(", ") %>% .[[1]] %>%
                    # Pad well numbers:
                    gsub("(\\D)(\\d)$", "\\10\\2", .) %>%
                    # Plate separator:
                    gsub("(\\d+)(\\D\\d{2})$", "-\\1-\\2", .) %>%
                    # ORFeome 96 well:
                    gsub("^-(\\d{5})-", "orfeome96-\\1-", .) %>%
                    # Ahringer 384 well:
                    gsub("^([IVX]{1,3})-", "ahringer384-\\1-", .) %>%
                    # Ahringer 96 well:
                    gsub("^-(\\d{1,3})-", "ahringer96-\\1-", .) %>%
                    # Present only `ahringer96` and `orfeome96` clones to user.
                    # Other identifiers (`ahringer96`, `cherrypick`) are for
                    # internal match functions only.
                    .[grepl("^(ahringer|orfeome)", .)] %>%
                    toStringSortUnique
            }
            return[[format]] <- identifier[a]
        }
        return
    }) %>% dplyr::bind_rows(.)
    if (nrow(return)) {
        dplyr::select_(return, .dots = unique(c(format, defaultCol, "clone")))
    }
}
