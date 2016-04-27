\name{metadata_report}
\alias{metadata_report}
\docType{data}
\title{metadata (readable report format)}
\description{
A subset of the master metadata file containing only human readable data.
}
\usage{data("metadata_report")}
\format{
  A data frame with 50930 observations on the following 23 variables.
  \describe{
    \item{\code{GeneID}}{a character vector}
    \item{\code{public.name}}{a character vector}
    \item{\code{ORF}}{a character vector}
    \item{\code{gene.other.ids}}{a character vector}
    \item{\code{description.gene.class}}{a character vector}
    \item{\code{description.concise}}{a character vector}
    \item{\code{description.provisional}}{a character vector}
    \item{\code{description.automated}}{a character vector}
    \item{\code{rnai.phenotypes}}{a character vector}
    \item{\code{orthologs.hsapiens.homolog.wormbase.name}}{a character vector}
    \item{\code{blastp.external.gene.name}}{a character vector}
    \item{\code{blastp.description}}{a character vector}
    \item{\code{biomart.gene.biotype}}{a character vector}
    \item{\code{biomart.ensembl.description}}{a character vector}
    \item{\code{biomart.ensembl.go.names}}{a character vector}
    \item{\code{biomart.interpro.description}}{a character vector}
    \item{\code{panther.family.name}}{a character vector}
    \item{\code{panther.subfamily.name}}{a character vector}
    \item{\code{panther.go.mf}}{a character vector}
    \item{\code{panther.go.bp}}{a character vector}
    \item{\code{panther.go.cc}}{a character vector}
    \item{\code{panther.pc}}{a character vector}
    \item{\code{panther.pathway}}{a character vector}
  }
}
\source{
WormBase (\url{http://www.wormbase.org})
Biomart (\url{http://www.biomart.org})
InterPro (\url{https://www.ebi.ac.uk/interpro})
PANTHER (\url{http://pantherdb.org})
}
\references{
%%  ~~ possibly secondary sources and usages ~~
}
\examples{
data(metadata_report)
## maybe str(metadata_report) ; plot(metadata_report) ...
}
\keyword{datasets}
