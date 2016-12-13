data(wormbaseGene)
wormbaseGeneExternal <- wormbaseRestGeneExternal(wormbaseGene$gene)
use_data(wormbaseGeneExternal, overwrite = TRUE)
