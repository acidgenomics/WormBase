data(wormbaseGene)
wormbaseGeneOntology <- restGeneOntology(wormbaseGene$gene) %>%
    setNamesCamel
use_data(wormbaseGeneOntology, overwrite = TRUE)
