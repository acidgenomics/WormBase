#' BioProject to query from FTP server
#'
#' @note Updated 2021-02-17.
#' @noRd
#'
#' @details
#' Canonical reference sequence:
#'
#' PRJNA13758
#' https://www.ncbi.nlm.nih.gov/bioproject/?term=PRJNA13758
#' Caenorhabditis elegans sequencing consortium project (2005)
#'
#' Other sequencing projects:
#'
#' PRJEB28388
#' https://www.ncbi.nlm.nih.gov/bioproject/?term=PRJEB28388
#' Caenorhabditis elegans strain VC2010 genome sequencing project (2018)
#'
#' PRJNA275000
#' https://www.ncbi.nlm.nih.gov/bioproject/?term=PRJNA275000
#' Caenorhabditis elegans Hawaiian strain CB4856 genome assembly (2015)
.bioproject <- "PRJNA13758"



#' Gene identifier pattern to use for grep matching
#'
#' @note Updated 2021-02-17.
#' @noRd
.genePattern <- "WBGene\\d{8}"



#' User agent to use for REST API calls
#'
#' @note Updated 2021-02-17.
#' @noRd
.userAgent <- "https://r.acidgenomics.com/packages/wormbase/"



#' Default release argument
#'
#' @note Updated 2021-02-17.
#' @noRd
.releaseArg <- quote(getOption(x = "wormbase.release", default = NULL))
