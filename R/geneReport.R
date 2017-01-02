#' Gene list report
#'
#' @export
#' @importFrom dplyr left_join
#' @param query Gene identifier
#' @return tibble
#'
#' @examples
#' geneReport("WBGene00000001")
geneReport <- function(query) {
    report <- gene(query, select = c(simpleCol,
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
                                     "pantherClass")) %>%
        dplyr::left_join(geneOntology(.$gene), by = "gene") %>%
        dplyr::left_join(geneExternal(.$gene), by = "gene") %>%
        dplyr::left_join(uniprot(.$gene), by = "gene")
    report$groupName <- report$eggnog %>%
        stringr::str_extract(., "ENOG41[A-Z0-9]{5}")
    report <- dplyr::left_join(report,
                               eggnog(x$groupName),
                               by = "groupName")
    report$groupName <- NULL
    return(report)
}

# reorder columns, sort by eggNog category then UniProt score confidence
# Write wormbaseCitation function -- PMID identifiers
