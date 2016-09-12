#' Get Entrez identifier from WormBase Gene identifier.
#'
#' @import dplyr
#' @import magrittr
#' @import stringr
#' @import xml2
#'
#' @param geneId WormBase gene identifier vector.
#'
#' @return tibble
#' @export
#'
#' @examples
#' wormbaseRestGeneExternal("WBGene00000001")
wormbaseRestGeneExternal <- function(geneId) {
    geneId <- sort(geneId) %>% unique %>% stats::na.omit(.)
    list <- lapply(seq_along(geneId), function(a) {
        rest <- httr::GET(paste0("http://api.wormbase.org/rest/widget/gene/", geneId[a], "/external_links"),
                          config = httr::content_type_json()) %>%
            httr::content(.)
        list(geneId = geneId[a],
             aceviewId = rest$fields$xrefs$data$AceView$gene$ids[[1]],
             ncbiId = rest$fields$xrefs$data$NCBI$gene$ids[[1]],
             refseqMrnaId = rest$fields$xrefs$data$RefSeq$mRNA$ids[[1]],
             refseqProteinId = rest$fields$xrefs$data$RefSeq$protein$ids[[1]],
             treefamId = rest$fields$xrefs$data$TREEFAM$TREEFAM_ID$ids[[1]],
             uniprotId = rest$fields$xrefs$data$UniProt$UniProtAcc$ids[[1]])
    })
    bind_rows(lapply(list, function(x) {
        as_tibble(Filter(Negate(is.null), x))
    }))
}
