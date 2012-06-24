\name{tm2codings-methods}
\docType{methods}
\alias{tm2codings}
\alias{tm2codings-methods}
\alias{tm2codings,Corpus-method}
\title{Methods for Function tm2codings in Package `RQDAtm'}
\description{
  This is methods for function \code{tm2codings} in Package `RQDAtm'. It extracts detail information from a Corpus and import it into a rqda project.
}
\section{Methods}{
\describe{
  \item{\code{signature(object = "Corpus")}}{
    This function extracts detail information from a Corpus object,
    convert it into a list of plain text. Then write the list of plain
    text into a rqda project by \code{\link[RQDA]{write.FileList}}.
    
    If meta of the object has a conponent of 'fname', then it is used a
    file names in rqda file. Otherwise, a numeric is assigned as file
    names.

    No return value, for its side effect only.
  }
}}
\author{
  J-P Mueller and revised and documented by HUANG Ronggui
}
\seealso{
  \code{\link{codings2tm}}
}
\examples{
\dontrun{
example(Corpus)
## open a rqda project first
tm2codings(r)
}
}
\keyword{methods}

