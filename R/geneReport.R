#' Gene list report
#'
#' @export
#' @importFrom dplyr arrange_ left_join select_
#' @param identifier Gene identifier
#' @return tibble
geneReport <- function(identifier) {
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
    geneExternal <- geneExternal(identifier)
    uniprot <- uniprot(identifier)
    eggnog <- uniprot$eggnog %>%
        strsplit(", ") %>% .[[1]] %>%
        eggnog %>%
        collapse

    gene %>%
        dplyr::left_join(geneExternal, by = "gene") %>%
        dplyr::left_join(geneOntology, by = "gene") %>%
        dplyr::left_join(uniprot, by = "gene") %>%
        dplyr::left_join(eggnog, by = "eggnog") %>%
        dplyr::select_(.dots = c("gene",
                                 setdiff(sort(names(.)), "gene"))) %>%
        dplyr::arrange_(.dots = c("gene"))
}
