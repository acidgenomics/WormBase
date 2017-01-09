#' Gene list report
#'
#' @export
#' @importFrom dplyr arrange_ bind_rows left_join select_
#' @param identifier Gene identifier
#' @return tibble
geneReport <- function(identifier) {
    identifier <- uniqueIdentifier(identifier)
    gene <- gene(identifier,
                 select = c(defaultCol,
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
        dplyr::select_(.dots = c(defaultCol,
                                 setdiff(sort(names(.)), defaultCol))) %>%
        dplyr::arrange_(.dots = defaultCol)
}
