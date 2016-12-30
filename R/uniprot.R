#' UniProt web service query
#'
#' @importFrom dplyr bind_rows rename_
#' @importFrom parallel mclapply
#' @importFrom pbmcapply pbmclapply
#' @importFrom UniProt.ws select UniProt.ws
#'
#' @param query WormBase identifier
#' @return tibble
#'
#' @export
uniprot <- function(query) {
    query <- query %>% stats::na.omit(.) %>% unique %>% sort
    if (length(query) < 100) {
        lapply <- parallel::mclapply
    } else {
        lapply <- pbmcapply::pbmclapply
    }
    database <- UniProt.ws::UniProt.ws(taxId = 6239)  # NCBI C. elegans
    lapply(seq_along(query), function(a) {
        key <- geneExternal(query[a]) %>%
            .[, "uniprot"] %>% .[[1]] %>%
            gsub(",.+$", "", .)
        UniProt.ws::select(database, keytype = "UNIPROTKB", keys = key,
                           columns = c("ENSEMBL_GENOMES",
                                       "EGGNOG",
                                       "CITATION",
                                       "ENTRY-NAME",
                                       "EXISTENCE",
                                       "FAMILIES",
                                       "FEATURES",
                                       "GENES",
                                       "GO",
                                       "GO-ID",
                                       "HOGENOM",
                                       "INTERPRO",
                                       "KEGG",
                                       "KEYWORDS",
                                       "LAST-MODIFIED",
                                       "ORTHODB",
                                       "PROTEIN-NAMES",
                                       "REVIEWED",
                                       "SCORE")) %>%
            collapse
    }) %>% dplyr::bind_rows(.) %>% setNamesCamel %>%
        dplyr::rename_(.dots = c("gene" = "ensemblGenomes"))
}
