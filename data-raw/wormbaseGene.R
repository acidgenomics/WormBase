gene <- wormbaseAnnotationFile("geneIDs") %>%
    read_csv(col_names = c("X", "gene", "name", "sequence", "status"),
             na = "") %>% select(-1)
geneOtherIdentifier <- wormbaseAnnotationFile("geneOtherIDs") %>%
    read_file %>%
    # Take out dead or live status, we have this already from
    # \code{wormbase$gene}:
    gsub("\t(Dead|Live)", "", .) %>%
    # Take the tabs out for gene list:
    gsub("\t", ", ", .) %>%
    # Add tab back in to separate \code{gene} for row names:
    gsub("WBGene([0-9]+), ", "WBGene\\1\t", .) %>%
    # Warnings here mean there are no other IDs for that row:
    # (e.g. expected: 2 columns, actual: 1 columns)
    read_tsv(col_names = c("gene", "otherIdentifier"))
wormbaseGene <- left_join(gene, geneOtherIdentifier, by = "gene")
use_data(wormbaseGene, overwrite = TRUE)
rm(gene, geneOtherIdentifier)
