library(dplyr)
library(magrittr)
library(seqcloudr)

data(wormbase)
wormbase <- Reduce(function(...) dplyr::full_join(..., by = "geneId"), wormbase) %>%
    dplyr::select(-eValue)

data(ensembl)
ensembl <- Reduce(function(...) dplyr::full_join(..., by = "ensembl_gene_id"), ensembl) %>%
    dplyr::rename(geneId = ensembl_gene_id,
                  ensembl_description = description) %>%
    magrittr::set_names(seqcloudr::camel(names(.)))

data(panther)
panther <- dplyr::select(panther, -c(protein, subfamilyId, uniprotKb))
names(panther)[2:length(panther)] <- paste("panther", names(panther)[2:length(panther)], sep = "_") %>%
    seqcloudr::camel(.)

geneData <- Reduce(function(...) dplyr::left_join(..., by = "geneId"), list(wormbase, ensembl, panther)) %>%
    seqcloudr::cruft(.)
devtools::use_data(geneData, overwrite = TRUE)
