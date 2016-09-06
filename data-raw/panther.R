library(dplyr)
library(magrittr)

file <- list.files(path = "data-raw", pattern = "PTHR*", full.names = TRUE)
if (!length(file)) {
    file <- seqcloudr::downloadFile("ftp://ftp.pantherdb.org/sequence_classifications/current_release/PANTHER_Sequence_Classification_files/", "nematode")
}
panther <- readr::read_tsv(file, col_names = FALSE) %>%
    set_names(c("id",
               "protein",
               "subfamilyId",
               "familyName",
               "subfamilyName",
               "geneOntologyMolecularFunction",
               "geneOntologyBiologicalProcess",
               "geneOntologyCellularComponent",
               "class",
               "pathway")) %>%
    mutate(id = gsub("CAEEL\\|", "", id)) %>%
    mutate(id = gsub("(EnsemblGenome|Gene|GeneID|UniProtKB|WormBase)=", "", id)) %>%
    tidyr::separate(id, c("geneId", "uniprotKb"), sep = "\\|") %>%
    # Fix incorrect ID mappings:
    mutate(geneId = gsub("^B0303.5$", "WBGene00015127", geneId)) %>%
    mutate(geneId = gsub("^C13B9.1$", "WBGene00015732", geneId)) %>%
    mutate(geneId = gsub("^F23F12.11/F23F12.5$", "WBGene00005075", geneId)) %>%
    mutate(geneId = gsub("^F55A11.4$", "WBGene00010077", geneId)) %>%
    mutate(geneId = gsub("^K02A2.6$", "WBGene00019291", geneId)) %>%
    mutate(geneId = gsub("^MTCE.11$", "WBGene00010959", geneId)) %>%
    mutate(geneId = gsub("^T07D3.8$", "WBGene00020310", geneId)) %>%
    mutate(geneId = gsub("^Y104H12A.1/Y77E11A.5$", "WBGene00022423", geneId)) %>%
    mutate(geneId = gsub("^Y62E10A.11$", "WBGene00014938", geneId)) %>%
    mutate(geneId = gsub("^176090$", "WBGene00022794", geneId)) %>%  # ZK686.4
    mutate(geneId = gsub("^2565696$", "WBGene00010966", geneId)) %>%  # MTCE.34
    mutate(geneId = gsub("^2565700$", "WBGene00010964", geneId)) %>%  # MTCE.26
    mutate(geneId = gsub("^2565701$", "WBGene00010962", geneId)) %>%  # MTCE.23
    mutate(geneId = gsub("^2565702$", "WBGene00000829", geneId)) %>%  # MTCE.21
    mutate(geneId = gsub("^2565703$", "WBGene00010967", geneId)) %>%  # MTCE.35
    mutate(geneId = gsub("^2565704$", "WBGene00010960", geneId)) %>%  # MTCE.12
    mutate(geneId = gsub("^2565705$", "WBGene00010963", geneId)) %>%  # MTCE.25
    # Change to `stringr::str_split` and make alphabetical here:
    mutate(geneOntologyBiologicalProcess = gsub(";", " // ", geneOntologyBiologicalProcess)) %>%
    mutate(geneOntologyBiologicalProcess = gsub("#GO:[0-9]+", "", geneOntologyBiologicalProcess)) %>%
    mutate(geneOntologyCellularComponent = gsub(";", " // ", geneOntologyCellularComponent)) %>%
    mutate(geneOntologyCellularComponent = gsub("#GO:[0-9]+", "", geneOntologyCellularComponent)) %>%
    mutate(geneOntologyMolecularFunction = gsub(";", " // ", geneOntologyMolecularFunction)) %>%
    mutate(geneOntologyMolecularFunction = gsub("#GO:[0-9]+", "", geneOntologyMolecularFunction)) %>%
    mutate(class = gsub(";", " // ", class)) %>%
    mutate(class = gsub("#PC[0-9]+", "", class)) %>%
    mutate(pathway = gsub(">", " > ", pathway)) %>%
    mutate(pathway = gsub(";", " // ", pathway)) %>%
    mutate(pathway = gsub("#P[0-9]+", "", pathway))
devtools::use_data(panther, overwrite = TRUE)
