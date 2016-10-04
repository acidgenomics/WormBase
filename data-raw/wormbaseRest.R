source("R/wormbaseRest.R")
library(devtools)
data(wormbase)
if (!exists("wormbase")) {
    source("data-raw/wormbase.R")
}

wormbaseGeneExternal <- wormbaseRestGeneExternal(wormbase$gene$gene)
devtools::use_data(wormbaseGeneExternal, overwrite = TRUE)

# Add RESTful query for ortholog widget
# Ensembl has some retired identifiers that don't match correctly
# For example, sbp-1 has the correct peptide but the ensembl gene is retired...
