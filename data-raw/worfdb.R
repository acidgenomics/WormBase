# WORFDB ====
if (!file.exists("data/worfdbHtml1.rda")) {
    data(wormbaseGene)
    sequence <- wormbaseGene$sequence
    worfdbHtml1 <- worfdbHtml(sequence)
    use_data(worfdbHtml1, overwrite = TRUE)
} else {
    data(worfdbHtml1)
}

worfdb1 <- worfdbData(worfdbHtml1)

if (!file.exists("data/worfdbHtml2.rda")) {
    # Download and analyze sequence remaps
    # Example: H15N14.1
    sequenceRemap <- worfdb1 %>%
        filter(!is.na(remap)) %>%
        .$remap %>% toString %>%
        str_split(", ") %>%
        unlist
    worfdbHtml2 <- worfdbHtml(sequenceRemap)
    use_data(worfdbHtml2, overwrite = TRUE)
} else {
    data(worfdbHtml2)
}

worfdb2 <- worfdbData(worfdbHtml2)

# Merge worfdb1 and worfdb2
worfdb <- bind_rows(worfdb1, worfdb2) %>%
    arrange(identifier, sequence)
use_data(worfdb, overwrite = TRUE)
rm(worfdb1, worfdb2)

flag <- worfdb %>% filter(grepl("does not confirm", sequencingInformation))

# Match to gene identifier with `gene()` function
x <- worfdb %>%
    select(-identifier) %>%
    filter(!is.na(sequence)) %>%
    left_join(worminfo::gene(.$sequence,
                             format = "sequence",
                             select = "gene"),
              by = "sequence")

