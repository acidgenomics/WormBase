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
    geneOntology <- geneOntology(identifier)
    uniprot <- uniprot(identifier)
    gene %>%
        dplyr::left_join(geneOntology, by = "gene") %>%
        dplyr::left_join(uniprot, by = "gene") %>%
        dplyr::select_(.dots = c(simpleCol,
                                 setdiff(sort(names(.)), simpleCol))) %>%
        dplyr::arrange_(.dots = simpleCol)
}
