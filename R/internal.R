defaultCol <- c("gene", "sequence", "name")



removeIsoform <- function(sequence) {
    grep <- "^([A-Z0-9]+)\\.([0-9]+)[a-z]$"
    if (any(grepl(grep, sequence))) {
        message("sequence identifiers should not end with an isoform")
        gsub(grep, "\\1.\\2", sequence)
    } else {
        sequence
    }
}



rest <- function(url) {
    GET(paste0("http://api.wormbase.org/rest/", url),
        config = content_type_json(),
        user_agent = user_agent(userAgent)) %>%
        content
}



uniqueIdentifier <- function(identifier) {
    if (missing(identifier)) {
        stop("identifier is required")
    } else if (!is.character(identifier)) {
        stop("identifier must be a character vector")
    }
    # Fix WBGene capitalization and alert user if necessary:
    grep <- "^(WBGENE|WBgene|Wbgene|wbgene)(\\d{8})$"
    if (any(grepl(grep, identifier))) {
        message("WormBase gene identifiers should begin with `WBGene`")
        identifier <- gsub(grep, "WBGene\\2", identifier)
    }
    identifier %>% sortUnique
}



userAgent <- "https://github.com/steinbaugh/worminfo"



wormbaseAnnotationFile <- function(file) {
    if (!file.exists("data-raw/wormbase")) {
        dir.create("data-raw/wormbase", recursive = TRUE)
    }
    root <- "ftp://ftp.wormbase.org/pub/wormbase/species/c_elegans/annotation/"
    version <- "canonical_bioproject.current"
    if (file == "best_blast_hits") {
        fileName <- "best_blastp_hits.txt.gz"
    } else {
        fileName <- paste0(file, ".txt.gz")
    }
    fileUrl <- paste0(root, file, "/c_elegans.", version, ".", fileName)
    filePath <- file.path("data-raw", "wormbase", fileName)
    if (!file.exists(filePath)) {
        download.file(fileUrl, filePath)
    }
    return(filePath)
}
