#' Gene list report
#'
#' @export
#' @importFrom dplyr arrange_ bind_rows left_join select_
#' @param identifier Gene identifier
#' @return tibble
geneReport <- function(identifier) {
    identifier <- identifier %>% stats::na.omit(.) %>% unique %>% sort
    gene <- gene(identifier,
                 select = c(simpleCol,
                            "class",
                            "biotype",
                            # Ortholog:
                            "blastpHsapiensGene",
                            "blastpHsapiensName",
                            "blastpHsapiensDescription",
                            "orthologHsapiens",
                            # Description:
                            "descriptionConcise",
                            "descriptionProvisional",
                            "descriptionAutomated",
                            "ensemblDescription",
                            # WormBase Additional:
                            "rnaiPhenotype",
                            # Gene Ontology:
                            "ensemblGeneOntology",
                            "interpro",
                            "pantherFamilyName",
                            "pantherSubfamilyName",
                            "pantherGeneOntologyMolecularFunction",
                            "pantherGeneOntologyBiologicalProcess",
                            "pantherGeneOntologyCellularComponent",
                            "pantherClass"))
    geneExternal <- geneExternal(identifier)
    geneOntology <- geneOntology(identifier)
    uniprot <- geneExternal$uniprot %>%
        toString %>%
        strsplit(", ") %>% .[[1]] %>%
        uniprot
    gene %>%
        dplyr::left_join(geneOntology, by = "gene") %>%
        dplyr::left_join(uniprot, by = "gene") %>%
        dplyr::select_(.dots = c("gene",
                                 setdiff(sort(names(.)), "gene"))) %>%
        dplyr::arrange_(.dots = c("gene"))
}
