#' Gene list report
#'
#' @param identifier Gene identifier
#' @param format Identifier format
#'
#' @return tibble
#' @export
geneReport <- function(identifier, format = "gene") {
    identifier <- uniqueIdentifier(identifier)
    gene <- gene(identifier,
                 format = format,
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
        identifier <- gene$gene
        return <- gene
        geneOntology <- geneOntology(identifier)
        if (nrow(geneOntology)) {
            return <- left_join(return, geneOntology, by = "gene")
        }
        uniprot <- uniprot(identifier)
        if (nrow(uniprot)) {
            return <- left_join(return, uniprot, by = "gene")
        }
        return %>%
            select_(.dots = c(defaultCol,
                              setdiff(sort(names(.)), defaultCol))) %>%
            arrange_(.dots = defaultCol)
    }
}
