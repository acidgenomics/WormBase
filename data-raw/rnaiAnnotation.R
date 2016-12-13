data(ahringer, orfeome)
ahringer <- ahringer %>%
    select(gene, genePair, ahringer384, ahringer96)
orfeome <- orfeome %>%
    select(gene, sequence, identifier) %>%
    rename(genePair = sequence,
           orfeome96 = identifier)
rnaiAnnotation <- bind_rows(ahringer, orfeome) %>%
    filter(!is.na(gene)) %>%
    group_by(gene) %>%
    rowCollapse
use_data(rnaiAnnotation, overwrite = TRUE)
rm(ahringer, orfeome)
