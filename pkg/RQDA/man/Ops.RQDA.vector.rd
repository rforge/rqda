\name{Ops.RQDA.vector}
\alias{\%and\%}
\alias{\%or\%}
\alias{\%not\%}
\title{ Binary operations of RQDA.vector}
\description{
  Binary operations of RQDA.vector
}
\usage{
e1 \%and\% e2
e1 \%or\% e2
e1 \%not\% e2
}
\arguments{
  \item{e1}{an object of class RQDA.vector.}
  \item{e2}{an object of class RQDA.vector.}
}
\details{
e1 and e2 are objects of class "RQDA.vector" includes classes of "fileId", "fileName", "caseId", "caseName". e1 and e2 must be the same class.

"&and&" is the \code{\link{intersect}} of e1 and e2. "%or%" is the \code{\link{union}} of e1 and e2. "%not%" is the defined as \code{setdiff(e1, e2)}.
}
\value{
a vector with the same class of e1 and e2.
}
\author{ HUANG Ronggui}
\seealso{ \code{\link{intersect}}, \code{\link{union}}, \code{\link{setdiff}}}
\examples{
\dontrun{
filesCodeByAnd(1:2) %and% filesCodeByAnd(3) ## coded by 1 and 2 as well as 3
filesCodeByAnd(1:2) %or% filesCodeByAnd(3) ## coded by 1 and 2 or 3
filesCodeByAnd(1:2) %not% filesCodeByAnd(3) ## coded by 1 and 2 but not 3
}
}
