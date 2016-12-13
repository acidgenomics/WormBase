raw <- wormbaseAnnotationFile("orthologs") %>%
    read_file %>%
    gsub("\t", " | ", .) %>%
    gsub("\n", " // ", .) %>%
    gsub("= // ", "\n", .) %>%
    gsub(" //  // ", "\t", .) %>%
    read_tsv(comment = "#", col_names = c("gene", "ortholog")) %>%
    mutate(gene = gsub("^(WBGene[0-9]{8}).*", "\\1", gene))
list <- split(raw, seq(nrow(raw)))
hsapiens <-
    mclapply(seq_along(list), function(a) {
        str_split(list[[a]][2], " // ")[[1]] %>%
            str_subset("Homo sapiens") %>%
            str_extract("ENSG[0-9]{11} \\| [^ ]+") %>%
            gsub(" \\| ", "~", .) %>%
            toStringUnique
    }) %>% unlist
wormbaseOrtholog <- tibble(gene = raw[[1]], hsapiens = hsapiens)
use_data(wormbaseOrtholog, overwrite = TRUE)
rm(hsapiens, list, raw)
