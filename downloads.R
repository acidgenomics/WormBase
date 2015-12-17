rm(list = ls(all.names = T))
if (!file.exists("downloads")) { dir.create("downloads") }
setwd("downloads")

# wormbase
# ftp://ftp.wormbase.org/pub/wormbase/
# http://www.wormbase.org/about/release_schedule
download.file("ftp://ftp.wormbase.org/pub/wormbase/species/c_elegans/annotation/geneIDs/c_elegans.PRJNA13758.WS251.geneIDs.txt.gz","geneIDs.txt.gz")
download.file("ftp://ftp.wormbase.org/pub/wormbase/species/c_elegans/annotation/functional_descriptions/c_elegans.PRJNA13758.WS250.functional_descriptions.txt.gz","functional_descriptions.txt.gz")
download.file("ftp://ftp.wormbase.org/pub/wormbase/species/c_elegans/annotation/orthologs/c_elegans.PRJNA13758.WS251.orthologs.txt.gz","orthologs.txt.gz")
download.file("ftp://ftp.wormbase.org/pub/wormbase/species/c_elegans/annotation/affy_oligo_mapping/c_elegans.PRJNA13758.WS251.affy_oligo_mapping.txt.gz","affy_oligo_mapping.txt.gz")
download.file("ftp://ftp.wormbase.org/pub/wormbase/species/c_elegans/annotation/agil_oligo_mapping/c_elegans.PRJNA13758.WS251.agil_oligo_mapping.txt.gz","agil_oligo_mapping.txt.gz")
download.file("ftp://ftp.wormbase.org/pub/wormbase/species/c_elegans/annotation/best_blast_hits/c_elegans.PRJNA13758.WS251.best_blastp_hits.txt.gz","best_blastp_hits.txt.gz")
download.file("ftp://ftp.wormbase.org/pub/wormbase/releases/WS251/ONTOLOGY/rnai_phenotypes_quick.WS251.wb","rnai.phenotypes.txt")
system("gzip --force rnai.phenotypes.txt")

# panther
# ftp://ftp.pantherdb.org//sequence_classifications/current_release
download.file("ftp://ftp.pantherdb.org/sequence_classifications/10.0/PANTHER_Sequence_Classification_files/PTHR10.0_nematode_worm","panther.txt")
system("gzip --force panther.txt")

setwd("../")
