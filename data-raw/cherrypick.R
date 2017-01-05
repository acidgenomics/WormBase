cherrypick <- read_excel("data-raw/cherrypick.xlsx") %>%
    mutate(clone = paste0(library,
                          plateNum,
                          plateRow,
                          plateCol)) %>%
    filter(!is.na(sequence)) %>%
    select(clone, sequence) %>%
    arrange(clone) %>%
    left_join(worminfo::gene(.$sequence, format = "sequence"), by = "sequence")
use_data(cherrypick, overwrite = TRUE)
