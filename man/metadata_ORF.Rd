\name{metadata_ORF}
\alias{metadata_ORF}
\docType{data}
\title{WormBase ORFs}
\description{
A dataset containing all current WormBase GeneIDs, public names,
open reading frames (ORFs), and previously used IDs. This dataset is filtered
to have unique ORF matches.
}
\usage{data("metadata_ORF")}
\format{
  A data frame with 47103 observations on the following 4 variables.
  \describe{
    \item{\code{GeneID}}{a character vector}
    \item{\code{ORF}}{a character vector}
    \item{\code{public.name}}{a character vector}
    \item{\code{gene.other.ids}}{a character vector}
  }
}
\source{\url{http://www.wormbase.org}}
\examples{
data(metadata_ORF)
}
\keyword{datasets}
