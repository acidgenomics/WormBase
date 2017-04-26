#' Ensembl utility functions
#'
#' @param gene Ensembl gene identifier
#' @param peptide Ensembl peptide identifier
#' @param nest Return as nested tibble
#'
#' @return Ensembl metadata



#' @rdname ensembl
#' @description Basic metadata
#' @export
#'
#' @examples
#' ensemblBasic("WBGene00000001") %>% glimpse
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
        meta <- as_tibble(meta) %>%
            rename(biotype = !!sym("gene_biotype"),
                   chromosome = !!sym("chromosome_name"),
                   gene = !!sym("ensembl_gene_id")) %>%
            setNamesCamel
        return(meta)
    }
}



#' @rdname ensembl
#' @description Gene Ontology terms
#' @export
#'
#' @examples
#' ensemblGeneOntology("WBGene00000001", nest = FALSE) %>% glimpse
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
        meta <- as_tibble(meta) %>%
            rename(gene = !!sym("ensembl_gene_id"),
                   geneOntology = !!sym("go_id"),
                   geneOntologyDescription = !!sym("name_1006")) %>%
            group_by(!!sym("gene"))
        if (isTRUE(nest)) {
            meta <- nest_(meta, "geneOntology")
        }
        return(meta)
    }
}



#' @rdname ensembl
#' @description InterPro metadata
#' @export
#'
#' @examples
#' ensemblInterpro("WBGene00000001", nest = FALSE) %>% glimpse
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
        meta <- as_tibble(meta) %>%
            rename(gene = !!sym("ensembl_gene_id")) %>%
            setNamesCamel %>%
            group_by(!!sym("gene"))
        if (isTRUE(nest)) {
            meta <- nest_(meta, "interpro")
        }
        return(meta)
    }
}




#' @rdname ensembl
#' @description \emph{H. sapiens} annotations for WormBase BLASTP peptide hits
#' @export
#'
#' @examples
#' ensemblPeptide("ENSP00000380252") %>% glimpse
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
        meta <- as_tibble(meta) %>%
            rename(peptide = !!sym("ensembl_peptide_id"),
                   hsapiensDescription = !!sym("description"),
                   hsapiensGene = !!sym("ensembl_gene_id"),
                   hsapiensName = !!sym("external_gene_name"))
        return(meta)
    }
}
