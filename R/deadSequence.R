#' Map dead ORF to WormBase Gene ID.
#'
#' @import dplyr
#' @import httr
#' @import stats
#'
#' @param sequence Sequence (ORF).
#'
#' @return tibble.
#' @export
#'
#' @examples
#' deadSequence("M01E10.2")
deadSequence <- function(sequence) {
    sequence <- sequence %>%
        stats::na.omit(.) %>%
        unique(.) %>%
        sort(.)
    list <- lapply(seq_along(sequence), function(a) {
        query <- sequence[a]
        request <- httr::GET(paste0("http://www.wormbase.org/search/gene/", query, "?species=c_elegans"),
                             config = httr::content_type_json())
        status <- httr::status_code(request)
        content <- httr::content(request)
        # WormBase seems to use the last entry for matching
        results <- rev(content$results)
        if (length(results)) {
            deadGene <- results[[1]]$name$id
            mergeGene <- results[[1]]$merged_into[[1]]$id
        }
        if (exists("mergeGene") && !is.null(mergeGene)) {
            gene <- mergeGene
        } else if (exists("deadGene") && !is.null(deadGene)) {
            gene <- deadGene
        } else {
            gene <- NA
        }
        list(genePair = query, gene = gene)
    })
    dplyr::bind_rows(list) %>%
        dplyr::filter(!is.na(gene))
}
