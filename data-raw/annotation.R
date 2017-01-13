dataRaw(c("build", "eggnog", "gene", "rnai"))
annotation <- list(gene = gene,
                   rnai = rnai,
                   eggnog = eggnog)
use_data(annotation, overwrite = TRUE)
