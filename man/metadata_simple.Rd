\name{metadata_simple}
\alias{metadata_simple}
\docType{data}
\title{metadata (simple version)}
\description{
A concise data frame containing only GeneID, ORF, public name, and other
previously used IDs.
}
\usage{data("metadata_simple")}
\format{
  A data frame with 50930 observations on the following 4 variables.
  \describe{
    \item{\code{GeneID}}{a character vector}
    \item{\code{ORF}}{a character vector}
    \item{\code{public.name}}{a character vector}
    \item{\code{gene.other.ids}}{a character vector}
  }
}
\source{
WormBase (\url{http://www.wormbase.org})
}
\examples{
data(metadata_simple)
}
\keyword{datasets}
