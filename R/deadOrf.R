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
        request <- GET(paste0("http://www.wormbase.org/search/gene/", query, "?species=c_elegans"),
                       config = content_type_json())
        status <- status_code(request)
        content <- content(request)
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
    bind_rows(list)
}
