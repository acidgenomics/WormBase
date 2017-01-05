dataRaw(c("cherrypick", "sourcebioscience", "worfdb"))
cherrypick <- cherrypick %>%
    select(gene, sequence, clone) %>%
    filter(!is.na(gene)) %>%
    rename(cherrypick = clone,
           genePair = sequence)
sourcebioscience <- sourcebioscience %>%
    select(gene, genePair, ahringer384, ahringer96)
worfdb <- worfdb %>%
    select(gene, sequence, clone) %>%
    rename(genePair = sequence,
           orfeome96 = clone)
rnaiAnnotation <- bind_rows(cherrypick,
                            sourcebioscience,
                            worfdb) %>%
    filter(!is.na(gene)) %>%
    group_by(gene) %>%
    collapse
use_data(rnaiAnnotation, overwrite = TRUE)
rm(cherrypick, sourcebioscience, worfdb)
