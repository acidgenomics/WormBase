data(sourcebioscience, worfdb)
ahringer <- sourcebioscience %>%
    select(gene, genePair, ahringer384, ahringer96)
orfeome <- worfdb %>%
    select(gene, sequence, clone) %>%
    rename(genePair = sequence,
           orfeome96 = clone)
rnaiAnnotation <- bind_rows(ahringer, orfeome) %>%
    filter(!is.na(gene)) %>%
    group_by(gene) %>%
    rowCollapse
use_data(rnaiAnnotation, overwrite = TRUE)
rm(ahringer,
   orfeome,
   sourcebioscience,
   worfdb)
