#' metadata
#'
#' C. elegans metadata pulled from WormBase, Ensembl, and PANTHER.
#'
#' @source
#' WormBase (\url{http://www.wormbase.org}),
#' Biomart (\url{http://www.biomart.org}),
#' InterPro (\url{https://www.ebi.ac.uk/interpro}),
#' PANTHER (\url{http://pantherdb.org})
#'
#' @format A data frame with 44 variables:
#'   \describe{
#'   \item{\code{geneId}}{a character vector}
#'   \item{\code{orf}}{a character vector}
#'   \item{\code{publicName}}{a character vector}
#'   \item{\code{wormbaseStatus}}{a character vector}
#'   \item{\code{wormbaseGeneOtherIds}}{a character vector}
#'   \item{\code{wormbaseConciseDescription}}{a character vector}
#'   \item{\code{wormbaseProvisionalDescription}}{a character vector}
#'   \item{\code{wormbaseDetailedDescription}}{a character vector}
#'   \item{\code{wormbaseAutomatedDescription}}{a character vector}
#'   \item{\code{wormbaseGeneClassDescription}}{a character vector}
#'   \item{\code{wormbaseRnaiPhenotypes}}{a character vector}
#'   \item{\code{wormbaseOrthologsHsapiensId}}{a character vector}
#'   \item{\code{wormbaseOrthologsHsapiensName}}{a character vector}
#'   \item{\code{wormbaseBlastpWormpepId}}{a character vector}
#'   \item{\code{wormbaseBlastpEnsemblPeptideId}}{a numeric vector}
#'   \item{\code{wormbaseBlastpEValue}}{a character vector}
#'   \item{\code{wormbaseBlastpEnsemblGeneId}}{a character vector}
#'   \item{\code{wormbaseBlastpEnsemblGeneName}}{a character vector}
#'   \item{\code{wormbaseBlastpEnsemblDescription}}{a character vector}
#'   \item{\code{ensemblGeneBiotype}}{a character vector}
#'   \item{\code{ensemblChromosomeName}}{a numeric vector}
#'   \item{\code{ensemblStartPosition}}{a numeric vector}
#'   \item{\code{ensemblEndPosition}}{a numeric vector}
#'   \item{\code{ensemblStrand}}{a character vector}
#'   \item{\code{ensemblDescription}}{a character vector}
#'   \item{\code{ensemblEntrezGeneId}}{a character vector}
#'   \item{\code{ensemblRefseqMrna}}{a character vector}
#'   \item{\code{ensemblRefseqNcrna}}{a character vector}
#'   \item{\code{ensemblUniprotSptrembl}}{a character vector}
#'   \item{\code{ensemblUniprotSwissprot}}{a character vector}
#'   \item{\code{ensemblGeneOntologyId}}{a character vector}
#'   \item{\code{ensemblGeneOntologyName}}{a character vector}
#'   \item{\code{ensemblInterpro}}{a character vector}
#'   \item{\code{ensemblInterproShortDescription}}{a character vector}
#'   \item{\code{ensemblInterproDescription}}{a character vector}
#'   \item{\code{pantherUniprotKb}}{a character vector}
#'   \item{\code{pantherSubfamilyId}}{a character vector}
#'   \item{\code{pantherFamilyName}}{a character vector}
#'   \item{\code{pantherSubfamilyName}}{a character vector}
#'   \item{\code{pantherGeneOntologyMolecularFunction}}{a character vector}
#'   \item{\code{pantherGeneOntologyBiologicalProcess}}{a character vector}
#'   \item{\code{pantherGeneOntologyCellularComponent}}{a character vector}
#'   \item{\code{pantherClass}}{a character vector}
#'   \item{\code{pantherPathway}}{a character vector}
#'   }
"metadata"


#' metadataOrf
#'
#' A dataset containing all current WormBase GeneIDs, public names, open reading
#' frames (ORFs), and previously used IDs. This dataset is filtered to have
#' unique ORF matches.
#'
#' @format A data frame with 3 variables: \code{geneId}, \code{orf},
#'   \code{publicName}
"metadataOrf"


#' metadataReport
#'
#' A subset of the master metadata file containing only human readable data.
#'
#' @format A data frame with 11 variables:
#'   \describe{
#'   \item{\code{geneId}}{a character vector}
#'   \item{\code{orf}}{a character vector}
#'   \item{\code{publicName}}{a character vector}
#'   \item{\code{wormbaseGeneClassDescription}}{a character vector}
#'   \item{\code{wormbaseConciseDescription}}{a character vector}
#'   \item{\code{wormbaseBlastpEnsemblGeneName}}{a character vector}
#'   \item{\code{wormbaseBlastpEnsemblDescription}}{a character vector}
#'   \item{\code{wormbaseStatus}}{a character vector}
#'   \item{\code{ensemblGeneBiotype}}{a character vector}
#'   \item{\code{pantherFamilyName}}{a character vector}
#'   \item{\code{pantherSubfamilyName}}{a character vector}
#'   }
"metadataReport"


#' metadataSimple
#'
#' A concise data frame containing only GeneID, ORF, and public name.
#'
#' @format A data frame with 3 variables: \code{geneId}, \code{orf},
#'   \code{publicName}
"metadataSimple"


#' ORFeome RNAi library annotations
#'
#' Developed for RNAi screens in C. elegans, this RNAi collection includes full
#' open reading frames for over 11,000 genes cloned into a feeding vector.
#'
#' @details
#' Derived from the C. elegans ORFeome Library v1.1, the C. elegans RNAi
#' collection provides comprehensive coverage for screening with over 11,000
#' RNAi clones. These constructs are cloned into the pL4440-dest-RNAi
#' Destination vector and are archived as glycerol stocks of the E. coli feeding
#' strain HT115(DE3). Minipreps of this DNA can be used as templates for in
#' vitro dsRNA synthesis before RNAi application by soaking or injection.
#'
#' @source
#' C .elegans RNAi Collection (\url{http://dharmacon.gelifesciences.com/non-mammalian-cdna-and-orf/c.-elegans-rnai}),
#' WORFDB (\url{http://worfdb.dfci.harvard.edu})
#'
#' @format A data frame with 5 variables:
#'   \describe{
#'   \item{\code{orfeomeId}}{a character vector}
#'   \item{\code{orfOriginal}}{a character vector}
#'   \item{\code{geneId}}{a character vector}
#'   \item{\code{orf}}{a character vector}
#'   \item{\code{publicName}}{a character vector}
#'   }
"orfeome"
