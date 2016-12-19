fileLocal <- "data-raw/dharmacon.xlsx"
if (!file.exists(fileLocal)) {
    download.file("http://dharmacon.gelifesciences.com/uploadedFiles/Resources/cernai-feeding-library.xlsx",
                  fileLocal)
}
dharmacon <- read_excel(fileLocal, sheet = 2) %>%
    setNamesCamel %>%
    select(orfIdWs112,
           plate,
           row,
           col) %>%
    filter(!is.na(plate)) %>%
    rename(sequence = orfIdWs112) %>%
    mutate(identifier = paste0(plate, row, col),
           sequence = gsub("no match in WS112", NA, sequence)) %>%
    filter(!is.na(sequence)) %>%
    select(noquote(order(names(.))))
use_data(dharmacon, overwrite = TRUE)
