#' Peptides
#'
#' @note Updated 2023-09-25.
#' @export
#'
#' @inheritParams params
#' @inheritParams AcidRoxygen::params
#'
#' @return `SplitDataFrameList`.
#' Split by `geneId` column.
#'
#' @examples
#' x <- peptides()
#' print(x)
peptides <- function(release = NULL) {
    file <- .assemblyFile(stem = "wormpep_package.tar.gz", release = release)
    tempdir <- tempdir2()
    releaseNumber <- strMatch(
        x = file,
        pattern = "WS([[:digit:]]{3})",
        fixed = FALSE
    )[1L, 2L]
    ## Extract the individual table.
    wormpepTable <- paste0("wormpep.table", releaseNumber)
    status <- untar(tarfile = file, files = wormpepTable, exdir = tempdir)
    assert(identical(status, 0L))
    x <- import(con = file.path(tempdir, wormpepTable), format = "lines")
    unlink2(tempdir)
    ## FIXME Switch back to mclapply when working.
    ## [1] ">2RSSE.1a wormpep=CE32785 gene=WBGene00007064 locus=rga-9 status=Confirmed uniprot=A4F337 insdc=CCD61138.1 product=\"Rho-GAP domain-containing protein\""
    x <- lapply(
        X = x,
        FUN = function(x) {
            ## FIXME Need to skip on no pattern.
            print(x)
            ## FIXME Need to handle empty string.
            seqPattern <- "^>([A-Za-z0-9\\.]+)\\s"
            sequence <- strMatch(
                x = x,
                pattern = seqPattern,
                fixed = FALSE
            )[1L, 2L]
            x <- sub(pattern = seqPattern, replacement = "", x = x)
            x <- strsplit(x, split = " ")[[1L]]
            x <- AcidBase::strSplit(x = x, split = "=")
            out <- x[, 2L]
            names(out) <- x[, 1L]
            out[["sequence"]] <- sequence
            out
        }
    )
    x <- rbindToDataFrame(x)
    colnames(x)[colnames(x) == "gene"] <- "geneId"
    x <- x[, unique(c("geneId", colnames(x)))]
    keep <- grepl(pattern = .genePattern, x = x[["geneId"]])
    x <- x[keep, , drop = FALSE]
    x <- x[
        order(x[["geneId"]], x[["sequence"]], x[["wormpep"]]), ,
        drop = FALSE
    ]
    x <- split(x, f = x[["geneId"]])
    assert(is(x, "SplitDataFrameList"))
    x
}

formals(peptides)[["release"]] <- .releaseArg
