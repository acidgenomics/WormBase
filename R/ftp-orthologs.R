#' Orthologs
#'
#' @note Updated 2021-02-18.
#' @export
#'
#' @inheritParams params
#' @inheritParams AcidRoxygen::params
#'
#' @return `List`.
#'
#' @examples
#' x <- orthologs()
#' print(x)
orthologs <- function(release = NULL) {
    file <- .annotationFile(stem = "orthologs.txt.gz", release = release)
    x <- import(file, format = "lines", comment = "#")
    x <- gsub("^=$", "\\|\\|", x)
    x <- paste(x, collapse = " ")
    x <- strsplit(x, "\\|\\|")[[1L]]
    x <- gsub("^ ", "", x)
    x <- x[grepl(paste0("^", .genePattern), x)]
    genes <- str_extract(string = x, pattern = .genePattern)
    assert(identical(length(genes), length(x)))
    patterns <- c(
        "danioRerio" = "\\bENSDARG\\d{11}\\b",
        "drosophilaMelanogaster" = "\\bFBgn\\d{7}\\b",
        "homoSapiens" = "\\bENSG\\d{11}\\b",
        "musMusculus" = "\\bENSMUSG\\d{11}\\b"
    )
    ## Attempting to coerce nested lists to CharacterList is slow here.
    x <- lapply(X = x, pattern = patterns, FUN = str_extract_all)
    x <- lapply(X = x, FUN = `names<-`, value = names(patterns))
    x <- List(x)
    names(x) <- genes
    keep <- grepl(pattern = .genePattern, x = names(x))
    x <- x[keep]
    x <- x[sort(names(x))]
    x
}

formals(orthologs)[["release"]] <- .releaseArg
