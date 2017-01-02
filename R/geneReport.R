# Split out the report special declaration from gene() function and rework here:
# Use UniProt then EggNOG
# Don't need to specify reportCol as a global variable when used here only.

# #' Report columns
# #' @param reportCol Report columns
# reportCol <- c(simpleCol,
#                "class",
#                # Ortholog:
#                "blastpHsapiensGene",
#                "blastpHsapiensName",
#                "blastpHsapiensDescription",
#                "orthologHsapiens",
#                # Description:
#                "descriptionConcise",
#                "descriptionProvisional",
#                "descriptionAutomated",
#                "ensemblDescription",
#                # WormBase Additional:
#                "rnaiPhenotype",
#                # Gene Ontology:
#                "ensemblGeneOntology",
#                "interpro",
#                "pantherFamilyName",
#                "pantherSubfamilyName",
#                "pantherGeneOntologyMolecularFunction",
#                "pantherGeneOntologyBiologicalProcess",
#                "pantherGeneOntologyCellularComponent",
#                "pantherClass")

# For EggNOG matching, use str_extract to pull only the LUCA identifier if both are present

#' Gene list report
#'
#' @param query
#'
#' @return tibble
#' @export
#'
#' @examples
#' geneReport("WBGene00000001")
geneReport <- function(query) {
    # if (select[[1]] == "report") {
    #     data <- data[, reportCol]
    #     # WormBase REST and UniProt.ws calls:
    #     data <- data %>%
    #         dplyr::left_join(geneOntology(.$gene), by = "gene") %>%
    #         dplyr::left_join(geneExternal(.$gene), by = "gene") %>%
    #         dplyr::left_join(uniprot(.$gene), by = "gene")
    # }
    query
}
