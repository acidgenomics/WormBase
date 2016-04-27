\name{GeneID}
\alias{GeneID}
\docType{data}
\title{WormBase GeneIDs}
\description{
A dataset containing all current WormBase GeneIDs, public names, ORFs,
WormBase status, and previously used IDs.
}
\usage{data("GeneID")}
\format{
  A data frame with 50930 observations on the following 5 variables.
  \describe{
    \item{\code{GeneID}}{a character vector}
    \item{\code{public.name}}{a character vector}
    \item{\code{ORF}}{a character vector}
    \item{\code{wormbase.status}}{a character vector}
    \item{\code{gene.other.ids}}{a character vector}
  }
}
\source{
WormBase (\url{http://www.wormbase.org})
}
\examples{
data(GeneID)
}
\keyword{datasets}
