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
#' c("GHR-11010@G06", "orfeome96-11010-G06", "ahringer384-III-6-C01", "ahringer96-86-B01") %>% rnai
#' "sbp-1" %>% rnai(format = "name")
#' "WBGene00004735" %>% rnai(format = "gene")
#' "Y47D3B.7" %>% rnai(format = "sequence")
#' "Y47D3B.7" %>% rnai(format = "genePair")
rnai <- function(identifier, format = "clone") {
    if (missing(identifier)) {
        stop("An identifier is required.")
    } else if (!is.character(identifier)) {
        stop("Identifier must be a character vector.")
    }
    identifier <- identifier %>% stats::na.omit(.) %>% unique %>% sort
    grep <- identifier
    annotation <- get("rnaiAnnotation", envir = asNamespace("worminfo"))
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
        # Strip out isoforms:
        grep <- gsub("^([A-Z0-9]+)\\.([0-9]+)[a-z]$", "\\1.\\2", grep)
    }
    # Now create the grep string:
    grep <- grep %>% grepString
    return <- parallel::mclapply(seq_along(grep), function(a) {
        return <- annotation %>% .[grepl(grep[a], .[[format]]), ]
        if (nrow(return)) {
            return[[format]] <- identifier[a]
        }
        return(return)
    }) %>% dplyr::bind_rows(.)
    if (nrow(return)) {
        if (format != "genePair") {
            return$genePair <- NULL
        }
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
                # Present only Ahringer and ORFeome clones to user:
                # Cherrypick identifiers are for internal matching only.
                .[grepl("^(ahringer|orfeome)", .)] %>%
                toStringSortUnique
        }
    }
    return(return)
}
