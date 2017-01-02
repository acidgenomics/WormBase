if (!file.exists("data-raw/eggnog")) {
    dir.create("data-raw/eggnog", recursive = TRUE)
}

# README:
download.file("http://eggnogdb.embl.de/download/latest/README.txt",
              "data-raw/eggnog/README.txt")



# Category ====
download.file("http://eggnogdb.embl.de/download/latest/COG_functional_categories.txt",
              "data-raw/eggnog/category.txt")
eggnogCategory <- readLines("data-raw/eggnog/category.txt") %>%
    .[grepl("^\\s\\[", .)] %>%
    # Strip leading and trailing spaces:
    gsub("^\\s|\\s$", "", .) %>%
    str_match("^\\[([A-Z])\\]\\s(.+)$") %>%
    .[, 2:3] %>%
    as_tibble %>%
    set_names(c("cogFunctionalCategory",
                "cogFunctionalDescription")) %>%
    arrange(cogFunctionalCategory)
use_data(eggnogCategory, overwrite = TRUE)



# Annotation ====
# Eukaryota:
download.file("http://eggnogdb.embl.de/download/latest/data/euNOG/euNOG.annotations.tsv.gz",
              "data-raw/eggnog/eunog.tsv.gz")

# LUCA (All organisms):
download.file("http://eggnogdb.embl.de/download/latest/data/NOG/NOG.annotations.tsv.gz",
              "data-raw/eggnog/nog.tsv.gz")

# See README.txt for annotation file column names:
colNames <- c("taxonomicLevel",
              "groupName",
              "proteinCount",
              "speciesCount",
              "cogFunctionalCategory",
              "consensusFunctionalDescription")
eunog <- read_tsv("data-raw/eggnog/eunog.tsv.gz", col_names = colNames)
nog <- read_tsv("data-raw/eggnog/nog.tsv.gz", col_names = colNames)
eggnogAnnotation <- bind_rows(eunog, nog)
use_data(eggnogAnnotation, overwrite = TRUE)
rm(eunog, nog)
