\name{rnai_orfeome}
\alias{rnai_orfeome}
\docType{data}
\title{C. elegans RNAi collection}
\description{
Developed for RNAi screens in C. elegans, this RNAi collection includes full
open reading frames for over 11,000 genes cloned into a feeding vector.
}
\usage{data("rnai_orfeome")}
\format{
  A data frame with 11559 observations on the following 5 variables.
  \describe{
    \item{\code{RNAi.well}}{a character vector}
    \item{\code{ORF}}{a character vector}
    \item{\code{GeneID}}{a character vector}
    \item{\code{public.name}}{a character vector}
    \item{\code{gene.other.ids}}{a character vector}
  }
}
\details{
Derived from the C. elegans ORFeome Library v1.1, the C. elegans RNAi collection
provides comprehensive coverage for screening with over 11,000 RNAi clones.
These constructs are cloned into the pL4440-dest-RNAi Destination vector and are
archived as glycerol stocks of the E. coli feeding strain HT115(DE3). Minipreps
of this DNA can be used as templates for in vitro dsRNA synthesis before RNAi
application by soaking or injection.
}
\source{
C .elegans RNAi Collection (\url{http://dharmacon.gelifesciences.com/non-mammalian-cdna-and-orf/c.-elegans-rnai}),
WORFDB (\url{http://worfdb.dfci.harvard.edu})
}
\examples{
data(rnai_orfeome)
}
\keyword{datasets}
