library(worminfo)
fileLocal <- "data-raw/sourcebioscience.xlsx"
if (!file.exists(fileLocal)) {
    download.file("http://www.us.lifesciences.sourcebioscience.com/media/381254/C.%20elegans%20Database%202012.xlsx",
                  fileLocal)
}
chromosomes <- c("I", "II", "III", "IV", "V", "X")
list <- mclapply(seq_along(chromosomes), function(a) {
    # Note that the first sheet contains notes, so \code{i + 1}
    read_excel(fileLocal, sheet = a + 1, col_types = rep("text", 8))
})
input <- bind_rows(list) %>%
    setNamesCamel %>%
    filter(!grepl("mismatch", extraInfo)) %>%
    rename(genePair = genePairsName,
           ahringer384 = sourceBioscienceLocation) %>%
    mutate(ahringer96 = paste0(plate, well),
           ahringer96 = gsub("([A-Z]{1})0", "\\1", ahringer96),
           ahringer384 = gsub("-", "", ahringer384),
           ahringer384 = gsub("([A-Z]{1})0", "\\1", ahringer384),
           fwdPrimerSeq = toupper(fwdPrimerSeq),
           revPrimerSeq = toupper(revPrimerSeq)) %>%
    select(-c(chrom, plate, well)) %>%
    arrange(genePair, ahringer384) %>%
    select(noquote(order(names(.))))
nrow(input)

matched <- list()

# Match `genePair` against `sequence` with `gene()` function:
matched$sequence <- input %>%
    mutate(sequence = gsub("^([A-Z0-9]+\\.[0-9]+)[a-z]$", "\\1", genePair)) %>%
    left_join(gene(.$sequence,
                   format = "sequence",
                   select = "gene"),
              by = "sequence") %>%
    filter(!is.na(gene))
unmatched <- input %>%
    filter(!genePair %in% matched[["sequence"]][["genePair"]])
nrow(matched$sequence)
nrow(unmatched)

# Match by `sjj_` oligo:
data(wormbaseOligo)
matched$oligo <- unmatched %>%
    mutate(oligo = paste0("sjj_", genePair)) %>%
    left_join(wormbaseOligo, by = "oligo") %>%
    filter(!is.na(gene))
unmatched <- unmatched %>%
    filter(!genePair %in% matched[["oligo"]][["genePair"]])
nrow(matched$oligo)
nrow(unmatched)

# Match by `sjj2_` oligo:
matched$oligo2 <- unmatched %>%
    mutate(oligo = paste0("sjj2_", genePair)) %>%
    left_join(wormbaseOligo, by = "oligo") %>%
    filter(!is.na(gene))
unmatched <- unmatched %>%
    filter(!genePair %in% matched[["oligo2"]][["genePair"]])
nrow(matched$oligo2)
nrow(unmatched)

sourcebioscience <- bind_rows(matched, unmatched)
use_data(sourcebioscience, overwrite = TRUE)
rm(chromosomes,
   fileLocal,
   list,
   input,
   matched,
   unmatched)
