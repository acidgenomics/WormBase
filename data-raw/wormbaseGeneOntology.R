data(wormbaseGene)
wormbaseGeneOntology <- geneOntology(wormbaseGene$gene) %>%
    setNamesCamel
use_data(wormbaseGeneOntology, overwrite = TRUE)
