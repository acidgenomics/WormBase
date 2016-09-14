#' Map dead ORF to WormBase Gene ID.
#' @import dplyr
#' @import httr
#' @param orf ORF vector.
#' @return tibble.
#' @examples
#' deadOrf("M01E10.2")
#' @export
deadOrf <- function(orf) {
    orf <- sort(orf) %>% unique %>% stats::na.omit(.)
    list <- lapply(seq_along(orf), function(a) {
        query <- orf[a]
        request <- httr::GET(paste0("http://www.wormbase.org/search/gene/", query, "?species=c_elegans"),
                             config = httr::content_type_json())
        status <- httr::status_code(request)
        content <- httr::content(request)
        # WormBase seems to use the last entry for matching
        results <- content$results %>% rev
        if (length(results)) {
            deadGeneId <- results[[1]]$name$id
            mergeGeneId <- results[[1]]$merged_into[[1]]$id
        }
        if (exists("mergeGeneId") && !is.null(mergeGeneId)) {
            geneId <- mergeGeneId
        } else if (exists("deadGeneId") && !is.null(deadGeneId)) {
            geneId <- deadGeneId
        } else {
            geneId <- NA
        }
        list(genePair = query, geneId = geneId)
    })
    dplyr::bind_rows(list) %>%
        dplyr::filter(!is.na(geneId))
}
