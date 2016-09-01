#' Gene annotations
#'
#' @param id Identifier
#' @param format Identifier type (geneID, orf, publicName)
#' @param output Output type (report, simple)
#'
#' @return \code{tibble}
#' @examples
#' gene()
#' gene(output = "simple")
#' gene(id = c("WBGene00004804", "WBGene00001752"), format = "geneId")
#' gene(id = c("T19E7.2", "K08F4.7"), format = "orf")
#' gene(id = c("skn-1", "gst-4"), format = "publicName")
#' @export
gene <- function(id = NULL, format = "geneId", output = "report") {
    tbl <- geneData

    # Strip ORF isoforms
    if (format == "orf") {
        id <- gsub("[a-z]{1}$", "", id)
    }

    # Subset if `id` declared
    if (!is.null(id)) {
        if (format == "geneId") {
            tbl <- subset(tbl, tbl$geneId %in% id)
        }
        if (format == "orf") {
            tbl <- subset(tbl, tbl$orf %in% id)
        }
        if (format == "publicName") {
            tbl <- subset(tbl, tbl$publicName %in% id)
        }
    }

    # Subset columns
    if (output == "report") {
        tbl <- tbl[, colNamesReport]
    }
    if (output == "simple") {
        tbl <- tbl[, colNamesSimple]
    }

    return(tbl)
}

#' geneData
#'
#' @format A data frame with 50970 observations on the following 42 variables.
#' \describe{
#'     \item{\code{geneId}}{a character vector}
#'     \item{\code{publicName}}{a character vector}
#'     \item{\code{orf}}{a character vector}
#'     \item{\code{status}}{a character vector}
#'     \item{\code{geneOtherIds}}{a character vector}
#'     \item{\code{conciseDescription}}{a character vector}
#'     \item{\code{provisionalDescription}}{a character vector}
#'     \item{\code{detailedDescription}}{a character vector}
#'     \item{\code{automatedDescription}}{a character vector}
#'     \item{\code{geneClassDescription}}{a character vector}
#'     \item{\code{rnaiPhenotypes}}{a character vector}
#'     \item{\code{hsapiensEnsemblGeneName}}{a character vector}
#'     \item{\code{hsapiensEnsemblGeneId}}{a character vector}
#'     \item{\code{wormpepId}}{a character vector}
#'     \item{\code{hsapiensBlastpEnsemblPeptideId}}{a character vector}
#'     \item{\code{hsapiensBlastpEnsemblGeneId}}{a character vector}
#'     \item{\code{hsapiensBlastpEnsemblGeneName}}{a character vector}
#'     \item{\code{hsapiensBlastpEnsemblDescription}}{a character vector}
#'     \item{\code{geneBiotype}}{a character vector}
#'     \item{\code{chromosomeName}}{a character vector}
#'     \item{\code{startPosition}}{a character vector}
#'     \item{\code{endPosition}}{a character vector}
#'     \item{\code{strand}}{a character vector}
#'     \item{\code{ensemblDescription}}{a character vector}
#'     \item{\code{entrezGeneId}}{a character vector}
#'     \item{\code{keggEnzyme}}{a character vector}
#'     \item{\code{refseqMrna}}{a character vector}
#'     \item{\code{refseqNcrna}}{a character vector}
#'     \item{\code{uniprotSptrembl}}{a character vector}
#'     \item{\code{uniprotSwissprot}}{a character vector}
#'     \item{\code{geneOntologyName}}{a character vector}
#'     \item{\code{geneOntologyId}}{a character vector}
#'     \item{\code{interproId}}{a character vector}
#'     \item{\code{interproDescription}}{a character vector}
#'     \item{\code{uniprotKb}}{a character vector}
#'     \item{\code{pantherFamilyName}}{a character vector}
#'     \item{\code{pantherSubfamilyName}}{a character vector}
#'     \item{\code{pantherGeneOntologyMolecularFunction}}{a character vector}
#'     \item{\code{pantherGeneOntologyBiologicalProcess}}{a character vector}
#'     \item{\code{pantherGeneOntologyCellularComponent}}{a character vector}
#'     \item{\code{pantherClass}}{a character vector}
#'     \item{\code{pantherPathway}}{a character vector}
#' }
#' @source
#' WormBase (\url{http://www.wormbase.org}),
#' Ensembl (\url{http://www.ensembl.org/Caenorhabditis_elegans}),
#' PANTHER (\url{http://pantherdb.org})
#' @examples
#' data(geneData)
geneData
