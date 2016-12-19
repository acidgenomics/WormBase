#' WormBase RESTful gene external query
#'
#' @import dplyr
#' @import httr
#' @import tibble
#'
#' @param gene Gene identifier
#'
#' @return JSON content tibble
#' @export
#'
#' @examples
#' restGeneExternal("WBGene00000001")
restGeneExternal <- function(gene) {
    gene <- gene %>% unique %>% sort
    list <- lapply(seq_along(gene), function(a) {
        rest <- paste0("widget/gene/", gene[a], "/external_links") %>% rest %>%
            .$fields %>% .$xrefs %>% .$data
        list(gene = gene[a],
             aceview = rest$AceView$gene$ids[[1]],
             ncbi = rest$NCBI$gene$ids[[1]],
             refseqMrna = rest$RefSeq$mRNA$ids[[1]],
             refseqProtein = rest$RefSeq$protein$ids[[1]],
             treefam = rest$TREEFAM$TREEFAM_ID$ids[[1]],
             uniprot = rest$UniProt$UniProtAcc$ids[[1]])
    })
    dplyr::bind_rows(lapply(list, function(a) {
        tibble::as_tibble(Filter(Negate(is.null), a))
    }))
}
