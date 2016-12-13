gsubs <- function(a) {
    a %>%
        # Separator spacing
        gsub("#", "~", .) %>%
        gsub("(^|;|>)([^~]+)~([A-Z0-9\\:]+)", "\\1\\3~\\2", .) %>%
        gsub(";", ", ", .) %>%
        gsub(">", " > ", .)
}
fileLocal <- "data-raw/panther.tsv.gz"
if (!file.exists(fileLocal)) {
    fileLocal <- downloadFile("ftp://ftp.pantherdb.org/sequence_classifications/current_release/PANTHER_Sequence_Classification_files/", "nematode")
    fileRename <- "data-raw/panther.tsv"
    file.rename(fileLocal, fileRename)
    fileLocal <- fileRename
    rm(fileRename)
    R.utils::gzip(fileLocal, overwrite = TRUE)
    fileLocal <- paste0(fileLocal, ".gz")
}
panther <- read_tsv(fileLocal, col_names = FALSE) %>%
    set_names(c("id",
                "protein",
                "subfamily",
                "familyName",
                "subfamilyName",
                "geneOntologyMolecularFunction",
                "geneOntologyBiologicalProcess",
                "geneOntologyCellularComponent",
                "class",
                "pathway")) %>%
    mutate(id = gsub("CAEEL\\|", "", id),
           id = gsub("(EnsemblGenome|Gene|GeneID|UniProtKB|WormBase)=", "", id)) %>%
    separate(id, c("gene", "uniprotKb"), sep = "\\|") %>%
    # Fix incorrect ID mappings:
    mutate(gene = gsub("^B0303.5$", "WBGene00015127", gene),
           gene = gsub("^C13B9.1$", "WBGene00015732", gene),
           gene = gsub("^F23F12.11/F23F12.5$", "WBGene00005075", gene),
           gene = gsub("^F55A11.4$", "WBGene00010077", gene),
           gene = gsub("^K02A2.6$", "WBGene00019291", gene),
           gene = gsub("^MTCE.11$", "WBGene00010959", gene),
           gene = gsub("^T07D3.8$", "WBGene00020310", gene),
           gene = gsub("^Y104H12A.1/Y77E11A.5$", "WBGene00022423", gene),
           gene = gsub("^Y62E10A.11$", "WBGene00014938", gene),
           gene = gsub("^176090$", "WBGene00022794", gene),
           gene = gsub("^2565696$", "WBGene00010966", gene),
           gene = gsub("^2565700$", "WBGene00010964", gene),
           gene = gsub("^2565701$", "WBGene00010962", gene),
           gene = gsub("^2565702$", "WBGene00000829", gene),
           gene = gsub("^2565703$", "WBGene00010967", gene),
           gene = gsub("^2565704$", "WBGene00010960", gene),
           gene = gsub("^2565705$", "WBGene00010963", gene)) %>%
    mutate_each(funs(gsubs)) %>%
    select(-c(protein, uniprotKb))
use_data(panther, overwrite = TRUE)
