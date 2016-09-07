utils::globalVariables(
    c(".",
      "type",
      "cloneData", "geneData",
      "geneId", "orf", "publicName",
      "ahringer96", "orfeome96", "sourceBioscience384")
)

colNamesSimple <-
    c("geneId",
      "orf",
      "publicName")

colNamesReport <-
    c(colNamesSimple,
      "geneOtherIds",
      "geneClassDescription",
      "conciseDescription",
      "provisionalDescription",
      "automatedDescription",
      "hsapiensBlastpGeneName",
      "hsapiensBlastpDescription",
      "status",
      "geneBiotype",
      "geneOntologyName",
      "geneOntologyId",
      "interproDescription",
      "interproId",
      "pantherFamilyName",
      "pantherSubfamilyName",
      "pantherGeneOntologyMolecularFunction",
      "pantherGeneOntologyBiologicalProcess",
      "pantherGeneOntologyCellularComponent",
      "pantherClass")
