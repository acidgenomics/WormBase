#' Get Entrez identifier from WormBase Gene identifier.
#'
#' @import httr
#' @import dplyr
#' @import stats
#' @import stringr
#' @import tibble
#' @import xml2
#'
#' @param gene WormBase gene identifier.
#'
#' @return tibble.
#' @export
#'
#' @examples
#' wormbaseRestGeneExternal("WBGene00000001")
wormbaseRestGeneExternal <- function(gene) {
    gene <- gene %>%
        stats::na.omit(.) %>%
        unique(.) %>%
        sort(.)
    list <- lapply(seq_along(gene), function(a) {
        rest <- httr::GET(paste0("http://api.wormbase.org/rest/widget/gene/", gene[a], "/external_links"),
                          config = httr::content_type_json()) %>%
            httr::content(.)
        list(gene = gene[a],
             aceview = rest$fields$xrefs$data$AceView$gene$ids[[1]],
             ncbi = rest$fields$xrefs$data$NCBI$gene$ids[[1]],
             refseqMrna = rest$fields$xrefs$data$RefSeq$mRNA$ids[[1]],
             refseqProtein = rest$fields$xrefs$data$RefSeq$protein$ids[[1]],
             treefam = rest$fields$xrefs$data$TREEFAM$TREEFAM_ID$ids[[1]],
             uniprot = rest$fields$xrefs$data$UniProt$UniProtAcc$ids[[1]])
    })
    dplyr::bind_rows(lapply(list, function(x) {
        tibble::as_tibble(Filter(Negate(is.null), x))
    }))
}
