library(dplyr)
library(magrittr)
library(readr)
library(tidyr)
file <- list.files(path = "data-raw", pattern = "PTHR*", full.names = TRUE)
if (!length(file)) {
    file <- seqcloudr::downloadFile("ftp://ftp.pantherdb.org/sequence_classifications/current_release/PANTHER_Sequence_Classification_files/", "nematode")
}
panther <- readr::read_tsv(file, col_names = FALSE) %>%
    magrittr::set_names(c("id",
                          "protein",
                          "subfamily",
                          "familyName",
                          "subfamilyName",
                          "geneOntologyMolecularFunction",
                          "geneOntologyBiologicalProcess",
                          "geneOntologyCellularComponent",
                          "class",
                          "pathway")) %>%
    mutate(id = gsub("CAEEL\\|", "", id)) %>%
    mutate(id = gsub("(EnsemblGenome|Gene|GeneID|UniProtKB|WormBase)=", "", id)) %>%
    tidyr::separate(id, c("gene", "uniprotKb"), sep = "\\|") %>%
    # Fix incorrect ID mappings:
    mutate(gene = gsub("^B0303.5$", "WBGene00015127", gene)) %>%
    mutate(gene = gsub("^C13B9.1$", "WBGene00015732", gene)) %>%
    mutate(gene = gsub("^F23F12.11/F23F12.5$", "WBGene00005075", gene)) %>%
    mutate(gene = gsub("^F55A11.4$", "WBGene00010077", gene)) %>%
    mutate(gene = gsub("^K02A2.6$", "WBGene00019291", gene)) %>%
    mutate(gene = gsub("^MTCE.11$", "WBGene00010959", gene)) %>%
    mutate(gene = gsub("^T07D3.8$", "WBGene00020310", gene)) %>%
    mutate(gene = gsub("^Y104H12A.1/Y77E11A.5$", "WBGene00022423", gene)) %>%
    mutate(gene = gsub("^Y62E10A.11$", "WBGene00014938", gene)) %>%
    mutate(gene = gsub("^176090$", "WBGene00022794", gene)) %>%  # ZK686.4
    mutate(gene = gsub("^2565696$", "WBGene00010966", gene)) %>%  # MTCE.34
    mutate(gene = gsub("^2565700$", "WBGene00010964", gene)) %>%  # MTCE.26
    mutate(gene = gsub("^2565701$", "WBGene00010962", gene)) %>%  # MTCE.23
    mutate(gene = gsub("^2565702$", "WBGene00000829", gene)) %>%  # MTCE.21
    mutate(gene = gsub("^2565703$", "WBGene00010967", gene)) %>%  # MTCE.35
    mutate(gene = gsub("^2565704$", "WBGene00010960", gene)) %>%  # MTCE.12
    mutate(gene = gsub("^2565705$", "WBGene00010963", gene)) %>%  # MTCE.25
    # Change to `stringr::str_split` and make alphabetical here:
    mutate(geneOntologyBiologicalProcess = gsub(";", " / ", geneOntologyBiologicalProcess)) %>%
    mutate(geneOntologyBiologicalProcess = gsub("#GO:[0-9]+", "", geneOntologyBiologicalProcess)) %>%
    mutate(geneOntologyCellularComponent = gsub(";", " / ", geneOntologyCellularComponent)) %>%
    mutate(geneOntologyCellularComponent = gsub("#GO:[0-9]+", "", geneOntologyCellularComponent)) %>%
    mutate(geneOntologyMolecularFunction = gsub(";", " / ", geneOntologyMolecularFunction)) %>%
    mutate(geneOntologyMolecularFunction = gsub("#GO:[0-9]+", "", geneOntologyMolecularFunction)) %>%
    mutate(class = gsub(";", " / ", class)) %>%
    mutate(class = gsub("#PC[0-9]+", "", class)) %>%
    mutate(pathway = gsub(">", " > ", pathway)) %>%
    mutate(pathway = gsub(";", " / ", pathway)) %>%
    mutate(pathway = gsub("#P[0-9]+", "", pathway)) %>%
    select(-c(protein, uniprotKb))
save(panther, file = "data-raw/panther.rda")
