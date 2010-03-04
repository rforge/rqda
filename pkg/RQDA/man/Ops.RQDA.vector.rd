\name{Ops.RQDA.vector}
\alias{Ops}
\title{ Binary operations of RQDA.vector}
\description{
  Binary operations of RQDA.vector
}
%\usage{
%}
%\arguments{
%  \item{e1}{an object of class RQDA.vector.}
%  \item{e2}{an object of class RQDA.vector.}
%}
\details{
Typical usage is as follows:
\preformatted{
    e1 & e2
    e1 | e2
    e1 - e2
          }
e1 and e2 are objects of class "RQDA.vector" includes classes of "fileId", "fileName", "caseId", "caseName".

"&" is the \code{\link{intersect}} of e1 and e2. "|" is the \code{\link{union}} of e1 and e2. "-" is the defined as \code{setdiff(e1, e2)}.

e1 and e2 must be the same class.
}
\value{
a vector with the same class of e1 and e2.
}
\author{ HUANG Ronggui}
\seealso{ \code{\link{intersect}}, \code{\link{union}}, \code{\link{setdiff}}}
\examples{
\dontrun{
getFiles(1:2) & getFiles(3) ## coded by 1 and 2 as well as 3
getFiles(1:2) | getFiles(3) ## coded by 1 and 2 or 3
getFiles(1:2) - getFiles(3) ## coded by 1 and 2 but not 3
}
}
