#' WormBase RESTful gene external query
#'
#' @import dplyr
#' @import magrittr
#' @import parallel
#' @import tibble
#'
#' @param identifier Gene identifier
#' @param all Keep all identifiers (\code{TRUE}/\code{FALSE})
#'
#' @return JSON content tibble
#' @export
#'
#' @examples
#' geneExternal("WBGene00000001")
geneExternal <- function(identifier, all = FALSE) {
    if (length(identifier) >= restLimit) {
        stop(paste0("A maximum of ", restLimit, " identifiers is allowed."))
    }
    result <- lapply(seq_along(identifier), function(a) {
        b <- identifier[[a]]
        if (!grepl("^WBGene[0-9]{8}$", b)) {
            stop("Invalid gene identifier.")
        }
        rest <- paste0("widget/gene/", b, "/external_links") %>%
            rest %>% .$fields %>% .$xrefs %>% .$data
        parallel::mclapply(seq_along(rest), function(c) {
            rest[[c]] %>% .[[1]] %>% .[[1]] %>%
                unlist %>% toStringUnique
        }) %>% magrittr::set_names(names(rest)) %>%
            tibble::as_tibble(.) %>%
            dplyr::mutate_(.dots = magrittr::set_names(list(~b), "gene"))
    }) %>% dplyr::bind_rows(.) %>%
        magrittr::set_names(tolower(names(.)))
    if (!isTRUE(all)) {
        result <- result[, c("gene", "ncbi", "uniprot")]
    }
    return(result)
}
