#' Get Entrez identifier from WormBase Gene identifier.
#'
#' @import httr
#' @import dplyr
#' @import stringr
#' @import tibble
#' @import xml2
#'
#' @param gene WormBase gene identifier.
#'
#' @return tibble.
#'
#' @export
#'
#' @examples
#' wormbaseRestGeneExternal("WBGene00000001")
wormbaseRestGeneExternal <- function(gene) {
    gene <- sort(gene) %>% unique %>% stats::na.omit(.)
    list <- lapply(seq_along(gene), function(a) {
        rest <- GET(paste0("http://api.wormbase.org/rest/widget/gene/", gene[a], "/external_links"),
                    config = content_type_json()) %>%
            content(.)
        list(gene = gene[a],
             aceview = rest$fields$xrefs$data$AceView$gene$ids[[1]],
             ncbi = rest$fields$xrefs$data$NCBI$gene$ids[[1]],
             refseqMrna = rest$fields$xrefs$data$RefSeq$mRNA$ids[[1]],
             refseqProtein = rest$fields$xrefs$data$RefSeq$protein$ids[[1]],
             treefam = rest$fields$xrefs$data$TREEFAM$TREEFAM_ID$ids[[1]],
             uniprot = rest$fields$xrefs$data$UniProt$UniProtAcc$ids[[1]])
    })
    bind_rows(lapply(list, function(x) {
        as_tibble(Filter(Negate(is.null), x))
    }))
}
