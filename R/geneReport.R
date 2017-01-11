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
    if (nrow(gene)) {
        return <- gene
        geneOntology <- geneOntology(identifier)
        if (nrow(geneOntology)) {
            return <- dplyr::left_join(return, geneOntology, by = "gene")
        }
        uniprot <- uniprot(identifier)
        if (nrow(uniprot)) {
            return <- dplyr::left_join(return, uniprot, by = "gene")
        }
        return %>%
            dplyr::select_(.dots = c(defaultCol,
                                     setdiff(sort(names(.)), defaultCol))) %>%
            dplyr::arrange_(.dots = defaultCol)
    }
}
