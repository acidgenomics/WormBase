cherrypickAnnotation <- read_excel("data-raw/cherrypickAnnotation.xlsx") %>%
    mutate(clone = paste0(library,
                          "-",
                          plateNum,
                          "-",
                          plateRow,
                          str_pad(plateCol, 2, pad = "0"))) %>%
    filter(!is.na(sequence)) %>%
    select(clone, sequence) %>%
    arrange(clone) %>%
    left_join(worminfo::gene(.$sequence, format = "sequence"), by = "sequence")
use_data(cherrypickAnnotation, overwrite = TRUE)
