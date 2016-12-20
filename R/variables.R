# Needed for piping
utils::globalVariables(c("."))



#' Simple columns
#' @param simpleCol Simple columns
simpleCol <- c("gene", "sequence", "name")



#' Keyword columns
#' @param keywordCol Keyword columns
keywordCol <- c("class",
                "blastpHsapiensDescription",
                "orthologHsapiens",
                "geneOntologyBiologicalProcess",
                "geneOntologyCellularComponent",
                "geneOntologyMolecularFunction",
                "ensemblGeneOntology",
                "interpro",
                "pantherClass",
                "pantherFamilyName",
                "pantherGeneOntologyBiologicalProcess",
                "pantherGeneOntologyCellularComponent",
                "pantherGeneOntologyMolecularFunction",
                "pantherPathway")



#' REST query limit
#' @param restLimit
restLimit = 1000



#' User agent
#' @param ua User agent
ua <- "https://github.com/steinbaugh/worminfo"
