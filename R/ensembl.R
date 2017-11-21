#' [Ensembl](http://www.ensembl.org) utility functions
#'
#' @rdname ensembl
#' @name ensembl
#'
#' @importFrom basejump camel
#' @importFrom biomaRt getBM useEnsembl
#' @importFrom dplyr group_by rename
#' @importFrom rlang !! sym
#' @importFrom tibble as_tibble
#' @importFrom tidyr nest
#'
#' @param gene Ensembl gene identifier.
#' @param peptide Ensembl peptide identifier.
#' @param nest Return as nested tibble.
#'
#' @return Ensembl metadata tibble.
#'
#' @examples
#' gene <- "WBGene00000001"
#' peptide <- "ENSP00000380252"
#' ensemblBasic(gene) %>% glimpse()
#' ensemblGeneOntology(gene, nest = FALSE) %>% glimpse()
#' ensemblInterpro(gene, nest = FALSE) %>% glimpse()
#' ensemblPeptide(peptide) %>% glimpse()
NULL



#' @rdname ensembl
#' @export
ensemblBasic <- function(gene = NULL) {
    if (is.null(gene)) {
        filters <- ""
        gene <- ""
    } else {
        filters <- "ensembl_gene_id"
        values <- gene
    }
    celegans <- useEnsembl("ensembl", "celegans_gene_ensembl")
    meta <- getBM(
        mart = celegans,
        filters = filters,
        values = values,
        attributes = c("ensembl_gene_id",
                       "description",
                       "gene_biotype",
                       "chromosome_name",
                       "start_position",
                       "end_position",
                       "strand"))
    if (nrow(meta)) {
        meta %>%
            as_tibble() %>%
            rename(biotype = !!sym("gene_biotype"),
                   chromosome = !!sym("chromosome_name"),
                   gene = !!sym("ensembl_gene_id")) %>%
            camel()
    }
}



#' @rdname ensembl
#' @importFrom dplyr group_by
#' @export
ensemblGeneOntology <- function(gene = NULL, nest = TRUE) {
    if (is.null(gene)) {
        filters <- ""
        gene <- ""
    } else {
        filters <- "ensembl_gene_id"
        values <- gene
    }
    celegans <- useEnsembl("ensembl", "celegans_gene_ensembl")
    meta <- getBM(
        mart = celegans,
        filters = filters,
        values = values,
        attributes = c("ensembl_gene_id",
                       "go_id",
                       "name_1006"))
    if (nrow(meta)) {
        meta <- meta %>%
            as_tibble() %>%
            rename(gene = !!sym("ensembl_gene_id"),
                   geneOntology = !!sym("go_id"),
                   geneOntologyDescription = !!sym("name_1006")) %>%
            group_by(!!sym("gene"))
        if (isTRUE(nest)) {
            meta <- nest(meta, .key = "geneOntology")
        }
        meta
    }
}



#' @rdname ensembl
#' @export
ensemblInterpro <- function(gene = NULL, nest = TRUE) {
    if (is.null(gene)) {
        filters <- ""
        values <- ""
    } else {
        filters <- "ensembl_gene_id"
        values <- gene
    }
    celegans <- useEnsembl("ensembl", "celegans_gene_ensembl")
    meta <- getBM(
        mart = celegans,
        filters = filters,
        values = values,
        attributes = c("ensembl_gene_id",
                       "interpro",
                       "interpro_description",
                       "interpro_short_description"))
    if (nrow(meta)) {
        meta <- meta %>%
            as_tibble() %>%
            rename(gene = !!sym("ensembl_gene_id")) %>%
            camel() %>%
            group_by(!!sym("gene"))
        if (isTRUE(nest)) {
            meta <- nest(meta, .key = "interpro")
        }
        meta
    }
}



#' @rdname ensembl
#' @export
ensemblPeptide <- function(peptide = NULL) {
    if (is.null(peptide)) {
        filters <- ""
        peptide <- ""
    } else {
        filters <- "ensembl_peptide_id"
    }
    hsapiens <- useEnsembl("ensembl", "hsapiens_gene_ensembl")
    meta <- getBM(
        mart = hsapiens,
        filters = filters,
        values = peptide,
        attributes = c("ensembl_peptide_id",
                       "ensembl_gene_id",
                       "external_gene_name",
                       "description"))
    if (nrow(meta)) {
        meta %>%
            as_tibble() %>%
            rename(peptide = !!sym("ensembl_peptide_id"),
                   hsapiensDescription = !!sym("description"),
                   hsapiensGene = !!sym("ensembl_gene_id"),
                   hsapiensName = !!sym("external_gene_name"))
    }
}
