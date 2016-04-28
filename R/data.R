#' GeneID
#'
#' A dataset containing all current WormBase GeneIDs, public names, ORFs,
#' WormBase status, and previously used IDs.
#'
#' @format A data frame with 5 variables: \code{GeneID}, \code{public.name},
#' \code{ORF}, \code{wormbase.status} and \code{gene.other.ids}.
"GeneID"


#' GeneID_vec
#'
#' A list of all the current WormBase GeneIDs available. Useful for setting data
#' frames to the same number of rows.
#'
#' @format A character vector.
"GeneID_vec"


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
#'   \item{\code{GeneID}}{a character vector}
#'   \item{\code{public.name}}{a character vector}
#'   \item{\code{ORF}}{a character vector}
#'   \item{\code{wormbase.status}}{a character vector}
#'   \item{\code{gene.other.ids}}{a character vector}
#'   \item{\code{description.gene.class}}{a character vector}
#'   \item{\code{description.concise}}{a character vector}
#'   \item{\code{description.provisional}}{a character vector}
#'   \item{\code{description.automated}}{a character vector}
#'   \item{\code{rnai.phenotypes}}{a character vector}
#'   \item{\code{orthologs.hsapiens.homolog.wormbase.id}}{a character vector}
#'   \item{\code{orthologs.hsapiens.homolog.wormbase.name}}{a character vector}
#'   \item{\code{blastp.wormbase.peptide.id}}{a character vector}
#'   \item{\code{blastp.ensembl.peptide.id}}{a character vector}
#'   \item{\code{blastp.e.val}}{a numeric vector}
#'   \item{\code{blastp.ensembl.gene.id}}{a character vector}
#'   \item{\code{blastp.external.gene.name}}{a character vector}
#'   \item{\code{blastp.description}}{a character vector}
#'   \item{\code{biomart.gene.biotype}}{a character vector}
#'   \item{\code{biomart.chromosome.name}}{a character vector}
#'   \item{\code{biomart.start.position}}{a numeric vector}
#'   \item{\code{biomart.end.position}}{a numeric vector}
#'   \item{\code{biomart.strand}}{a numeric vector}
#'   \item{\code{biomart.ensembl.description}}{a character vector}
#'   \item{\code{biomart.entrezgene}}{a character vector}
#'   \item{\code{biomart.refseq.mrna}}{a character vector}
#'   \item{\code{biomart.refseq.ncrna}}{a character vector}
#'   \item{\code{biomart.uniprot.sptrembl}}{a character vector}
#'   \item{\code{biomart.uniprot.swissprot}}{a character vector}
#'   \item{\code{biomart.hsapiens.homolog.ensembl.gene}}{a character vector}
#'   \item{\code{biomart.ensembl.go.id}}{a character vector}
#'   \item{\code{biomart.ensembl.go.names}}{a character vector}
#'   \item{\code{biomart.interpro}}{a character vector}
#'   \item{\code{biomart.interpro.short.description}}{a character vector}
#'   \item{\code{biomart.interpro.description}}{a character vector}
#'   \item{\code{panther.uniprot.kb}}{a character vector}
#'   \item{\code{panther.sf.id}}{a character vector}
#'   \item{\code{panther.family.name}}{a character vector}
#'   \item{\code{panther.subfamily.name}}{a character vector}
#'   \item{\code{panther.go.mf}}{a character vector}
#'   \item{\code{panther.go.bp}}{a character vector}
#'   \item{\code{panther.go.cc}}{a character vector}
#'   \item{\code{panther.pc}}{a character vector}
#'   \item{\code{panther.pathway}}{a character vector}
#'   }
"metadata"


#' metadata_ORF
#'
#' A dataset containing all current WormBase GeneIDs, public names, open reading
#' frames (ORFs), and previously used IDs. This dataset is filtered to have
#' unique ORF matches.
#'
#' @format A data frame with 4 variables: \code{GeneID}, \code{ORF},
#' \code{public.name}, \code{gene.other.ids}
"metadata_ORF"


#' metadata_report
#'
#' A subset of the master metadata file containing only human readable data.
#'
#' @format A data frame with 23 variables:
#'   \describe{
#'   \item{\code{GeneID}}{a character vector}
#'   \item{\code{public.name}}{a character vector}
#'   \item{\code{ORF}}{a character vector}
#'   \item{\code{gene.other.ids}}{a character vector}
#'   \item{\code{description.gene.class}}{a character vector}
#'   \item{\code{description.concise}}{a character vector}
#'   \item{\code{description.provisional}}{a character vector}
#'   \item{\code{description.automated}}{a character vector}
#'   \item{\code{rnai.phenotypes}}{a character vector}
#'   \item{\code{orthologs.hsapiens.homolog.wormbase.name}}{a character vector}
#'   \item{\code{blastp.external.gene.name}}{a character vector}
#'   \item{\code{blastp.description}}{a character vector}
#'   \item{\code{biomart.gene.biotype}}{a character vector}
#'   \item{\code{biomart.ensembl.description}}{a character vector}
#'   \item{\code{biomart.ensembl.go.names}}{a character vector}
#'   \item{\code{biomart.interpro.description}}{a character vector}
#'   \item{\code{panther.family.name}}{a character vector}
#'   \item{\code{panther.subfamily.name}}{a character vector}
#'   \item{\code{panther.go.mf}}{a character vector}
#'   \item{\code{panther.go.bp}}{a character vector}
#'   \item{\code{panther.go.cc}}{a character vector}
#'   \item{\code{panther.pc}}{a character vector}
#'   \item{\code{panther.pathway}}{a character vector}
#'   }
"metadata_report"


#' metadata_simple
#'
#' A concise data frame containing only GeneID, ORF, public name, and other
#' previously used IDs.
#'
#' @format A data frame with 4 variables: \code{GeneID}, \code{ORF},
#' \code{public.name}, \code{gene.other.ids}
"metadata_simple"


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
#' @format A data frame with 7 variables:
#'   \describe{
#'   \item{\code{ORFeomeID}}{a character vector}
#'   \item{\code{ORF.original}}{a character vector}
#'   \item{\code{RNAi.well}}{a character vector}
#'   \item{\code{GeneID}}{a character vector}
#'   \item{\code{ORF}}{a character vector}
#'   \item{\code{public.name}}{a character vector}
#'   \item{\code{gene.other.ids}}{a character vector}
#'   }
"rnai_orfeome"
