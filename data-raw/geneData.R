library(dplyr)
library(seqcloudr)

data(wormbase)
wormbase <- Reduce(function(...) full_join(..., by = "geneId"), wormbase) %>%
  select(-eValue)

data(ensembl)
ensembl <- Reduce(function(...) full_join(..., by = "ensembl_gene_id"), ensembl) %>%
  rename(geneId = ensembl_gene_id,
         ensembl_description = description) %>%
  setNames(camel(names(.)))

data(panther)
panther <- select(panther, -c(protein, subfamilyId))
names(panther)[3:length(panther)] <- paste("panther", names(panther)[3:length(panther)], sep = "_") %>% camel

geneData <- Reduce(function(...) left_join(..., by = "geneId"), list(wormbase, ensembl, panther)) %>% cruft
devtools::use_data(geneData, overwrite = TRUE)
