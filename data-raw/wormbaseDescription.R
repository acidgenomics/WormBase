file <- wormbaseAnnotationFile("functional_descriptions")
names <- read_lines(file, n_max = 1, skip = 3) %>%
    str_split(" ") %>%
    .[[1]] %>%
    str_replace("(\\w+)_description$", "description_\\1") %>%
    camel %>%
    str_replace("descriptionGeneClass", "class") %>%
    str_replace("geneId", "gene") %>%
    str_replace("molecularName", "sequence") %>%
    str_replace("publicName", "name")
print(names)
wormbaseDescription <-
    read_delim(file, delim = "\t",
               col_names = names,
               skip = 4,
               na = c("", "none available", "not known")) %>%
    select(-c(name, sequence)) %>%
    filter(grepl("^WBGene[0-9]+$", gene))
use_data(wormbaseDescription, overwrite = TRUE)
rm(file, names)
