loadData(c("sourcebioscience", "worfdb"))
sourcebioscience <- sourcebioscience %>%
    select(gene, genePair, ahringer384, ahringer96)
worfdb <- worfdb %>%
    select(gene, sequence, clone) %>%
    rename(genePair = sequence,
           orfeome96 = clone)
rnaiAnnotation <- bind_rows(sourcebioscience, worfdb) %>%
    filter(!is.na(gene)) %>%
    group_by(gene) %>%
    collapse
use_data(rnaiAnnotation, overwrite = TRUE)
rm(sourcebioscience, worfdb)
