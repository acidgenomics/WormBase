dataRaw(c("wormbaseGene",  # must go first
           "wormbaseBlastp",
           "wormbaseDescription",
           "wormbaseOligo",
           "wormbaseOrtholog",
           "wormbaseRnaiPhenotype",
           "ensembl",
           "panther"))

# Add `blastp` prefix:
names(wormbaseBlastp)[2:length(wormbaseBlastp)] <-
    paste("blastp", names(wormbaseBlastp)[2:length(wormbaseBlastp)], sep = "_") %>%
    camel

# Add `ensembl` prefix:
ensembl <- ensembl %>%
    rename(ensemblDescription = description,
           ensemblGeneOntology = geneOntology)

# Add `ortholog` prefix:
wormbaseOrtholog <- wormbaseOrtholog %>%
    rename(orthologHsapiens = hsapiens)

# Add `panther` prefix:
names(panther)[2:length(panther)] <-
    paste("panther", names(panther)[2:length(panther)], sep = "_") %>%
    camel

gene <-
    Reduce(function(...) { left_join(..., by = "gene") },
           list(wormbaseGene, # must go first
                wormbaseBlastp,
                wormbaseDescription,
                wormbaseOrtholog,
                wormbaseRnaiPhenotype,
                ensembl,
                panther)) %>%
    as_tibble %>%
    wash %>%
    setNamesCamel %>%
    select(noquote(order(names(.)))) %>%
    arrange(gene)
use_data(gene, overwrite = TRUE)

