# Needed for piping
utils::globalVariables(c("."))



#' Simple columns
#' @param simpleCol Simple columns
simpleCol <- c("gene", "sequence", "name")



#' Report columns
#' @param reportCol Report columns
reportCol <- c(simpleCol,
               "class",
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
               "pantherClass")



#' REST query limit
#' @param restLimit REST query limit
restLimit = 1000



#' User agent
#' @param ua User agent
ua <- "https://github.com/steinbaugh/worminfo"
