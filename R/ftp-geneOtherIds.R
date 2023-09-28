#' Other gene identifiers
#'
#' @note As of WS269 release, some non-N2 gene IDs are included in the flat
#' files available on the WormBase FTP server. These annotations are removed
#' from the return here, using grep matching to return only `WBGene` entries.
#'
#' @note Updated 2021-02-18.
#' @export
#'
#' @inheritParams params
#' @inheritParams AcidRoxygen::params
#'
#' @return `CharacterList`.
#'
#' @examples
#' x <- geneOtherIds()
#' print(x)
geneOtherIds <- function(release = NULL) {
    file <- .annotationFile(stem = "geneOtherIDs.txt.gz", release = release)
    x <- import(file, format = "lines")
    ## Remove status. Already present in `geneIds` file.
    x <- gsub("\t(Dead|Live)", "", x)
    ## Remove `CELE_*` identifiers.
    x <- gsub("\t(CELE_[A-Z0-9\\.]+)", "", x)
    ## Convert tabs to commas for identifiers.
    x <- gsub("\t", "|", x)
    ## Add tab back in to separate \code{gene} for row names.
    x <- gsub("^(WBGene\\d+)(\\|)?", "\\1\t", x)
    ## Break out the chain and evaluate.
    x <- strsplit(x, "\t")
    x <- CharacterList(x)
    df <- DataFrame(do.call(rbind, x))
    colnames(df) <- c("geneId", "geneOtherIds")
    keep <- grepl(pattern = .genePattern, x = df[["geneId"]])
    df <- df[keep, , drop = FALSE]
    x <- CharacterList(strsplit(
        x = as.character(df[["geneOtherIds"]]),
        split = "\\|"
    ))
    names(x) <- df[["geneId"]]
    keep <- grepl(pattern = .genePattern, x = names(x))
    x <- x[keep]
    x <- x[sort(names(x))]
    x <- sort(unique(x))
    x
}

formals(geneOtherIds)[["release"]] <- .releaseArg
