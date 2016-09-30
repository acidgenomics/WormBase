keyword <- function(keyword, ...) {
    source <- get("geneSource", envir = asNamespace("worminfo"))
    source <- source[, c("gene",
                         "blastpHsapiensDescription",
                         "class",
                         "descriptionAutomated",
                         "descriptionConcise",
                         "descriptionDetailed",
                         "descriptionProvisional",
                         "geneOntologyName",
                         "interproName",
                         "pantherClass",
                         "pantherFamilyName",
                         "pantherGeneOntologyBiologicalProcess",
                         "pantherGeneOntologyCellularComponent",
                         "pantherGeneOntologyMolecularFunction",
                         "pantherPathway")]

    # `1` denotes rows here
    grepl <- apply(source, 1, function(a) {
        any(grepl(keyword, a, ignore.case = TRUE))
    })
    identifier <- source[grepl, "gene"]
    identifier <- identifier[[1]]
    data <- gene(identifier, ...)
    return(data)
}
